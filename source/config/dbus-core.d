module config.dbus_core;
@nogc nothrow:
extern(C): __gshared:
/*
 * Copyright © 2006-2007 Daniel Stone
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice (including the next
 * paragraph) shall be included in all copies or substantial portions of the
 * Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Author: Daniel Stone <daniel@fooishbar.org>
 */

import build.dix_config;

import dbus.dbus;
import core.sys.posix.sys.select;

import os.log_priv;

import include.dix;
import os;

import config.dbus_core;

/* How often to attempt reconnecting when we get booted off the bus. */
enum RECONNECT_DELAY = (10 * 1000)     /* in ms */;

struct dbus_core_info {
    int fd;
    DBusConnection* connection;
    OsTimerPtr timer;
    dbus_core_hook* hooks;
}
private dbus_core_info bus_info = { fd: -1 };



private void socket_handler(int fd, int ready, void* data)
{
    dbus_core_info* info = data;

    if (info.connection) {
        do {
            dbus_connection_read_write_dispatch(info.connection, 0);
        } while (info.connection &&
                 dbus_connection_get_is_connected(info.connection) &&
                 dbus_connection_get_dispatch_status(info.connection) ==
                 DBUS_DISPATCH_DATA_REMAINS);
    }
}

/**
 * Disconnect (if we haven't already been forcefully disconnected), clean up
 * after ourselves, and call all registered disconnect hooks.
 */
private void teardown()
{
    dbus_core_hook* hook = void;

    if (bus_info.timer) {
        TimerFree(bus_info.timer);
        bus_info.timer = null;
    }

    /* We should really have pre-disconnect hooks and run them here, for
     * completeness.  But then it gets awkward, given that you can't
     * guarantee that they'll be called ... */
    if (bus_info.connection)
        dbus_connection_unref(bus_info.connection);

    if (bus_info.fd != -1)
        RemoveNotifyFd(bus_info.fd);
    bus_info.fd = -1;
    bus_info.connection = null;

    for (hook = bus_info.hooks; hook; hook = hook.next) {
        if (hook.disconnect)
            hook.disconnect(hook.data);
    }
}

/**
 * This is a filter, which only handles the disconnected signal, which
 * doesn't go to the normal message handling function.  This takes
 * precedence over the message handling function, so have have to be
 * careful to ignore anything we don't want to deal with here.
 */
private DBusHandlerResult message_filter(DBusConnection* connection, DBusMessage* message, void* data)
{
    /* If we get disconnected, then take everything down, and attempt to
     * reconnect immediately (assuming it's just a restart).  The
     * connection isn't valid at this point, so throw it out immediately. */
    if (dbus_message_is_signal(message, DBUS_INTERFACE_LOCAL, "Disconnected")) {
        DebugF("[dbus-core] disconnected from bus\n");
        bus_info.connection = null;
        teardown();

        if (bus_info.timer)
            TimerFree(bus_info.timer);
        bus_info.timer = TimerSet(null, 0, 1, reconnect_timer, null);

        return DBUS_HANDLER_RESULT_HANDLED;
    }

    return DBUS_HANDLER_RESULT_NOT_YET_HANDLED;
}

/**
 * Attempt to connect to the system bus, and set a filter to deal with
 * disconnection (see message_filter above).
 *
 * @return 1 on success, 0 on failure.
 */
private int connect_to_bus()
{
    DBusError error = void;
    dbus_core_hook* hook = void;

    dbus_error_init(&error);
    bus_info.connection = dbus_bus_get(DBUS_BUS_SYSTEM, &error);
    if (!bus_info.connection || dbus_error_is_set(&error)) {
        LogMessage(X_ERROR, "dbus-core: error connecting to system bus: %s (%s)\n",
               error.name, error.message);
        goto err_begin;
    }

    /* Thankyou.  Really, thankyou. */
    dbus_connection_set_exit_on_disconnect(bus_info.connection, FALSE);

    if (!dbus_connection_get_unix_fd(bus_info.connection, &bus_info.fd)) {
        ErrorF("[dbus-core] couldn't get fd for system bus\n");
        goto err_unref;
    }

    if (!dbus_connection_add_filter(bus_info.connection, &message_filter,
                                    &bus_info, null)) {
        ErrorF("[dbus-core] couldn't add filter: %s (%s)\n", error.name,
               error.message);
        goto err_fd;
    }

    dbus_error_free(&error);
    SetNotifyFd(bus_info.fd, &socket_handler, X_NOTIFY_READ, &bus_info);

    for (hook = bus_info.hooks; hook; hook = hook.next) {
        if (hook.connect)
            hook.connect(bus_info.connection, hook.data);
    }

    return 1;

 err_fd:
    bus_info.fd = -1;
 err_unref:
    dbus_connection_unref(bus_info.connection);
    bus_info.connection = null;
 err_begin:
    dbus_error_free(&error);

    return 0;
}

private CARD32 reconnect_timer(OsTimerPtr timer, CARD32 time, void* arg)
{
    if (connect_to_bus()) {
        TimerFree(bus_info.timer);
        bus_info.timer = null;
        return 0;
    }
    else {
        return RECONNECT_DELAY;
    }
}

int dbus_core_add_hook(dbus_core_hook* hook)
{
    dbus_core_hook** prev = void;

    for (prev = &bus_info.hooks; *prev; prev = &(*prev).next){}

    hook.next = null;
    *prev = hook;

    /* If we're already connected, call the connect hook. */
    if (bus_info.connection)
        hook.connect(bus_info.connection, hook.data);

    return 1;
}

void dbus_core_remove_hook(dbus_core_hook* hook)
{
    dbus_core_hook** prev = void;

    for (prev = &bus_info.hooks; *prev; prev = &(*prev).next) {
        if (*prev == hook) {
            *prev = hook.next;
            break;
        }
    }
}

int dbus_core_init()
{
    memset(&bus_info, 0, bus_info.sizeof);
    bus_info.fd = -1;
    bus_info.hooks = null;
    if (!connect_to_bus())
        bus_info.timer = TimerSet(null, 0, 1, &reconnect_timer, null);

    return 1;
}

void dbus_core_fini()
{
    teardown();
}
