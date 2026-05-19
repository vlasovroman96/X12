module ossock.c;
@nogc nothrow:
extern(C): __gshared:
import core.stdc.config: c_long, c_ulong;
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 */
import build.dix_config;

import core.sys.posix.unistd;
import stdbool;

version (Windows) {
import deimos.X11.Xwinsock;
} else {
import core.sys.posix.sys.ioctl;
}

import os.ossock;

void ossock_init()
{
version (Windows) {
    static WSADATA wsadata;
    if (!wsadata.wVersion)
        WSAStartup(0x0202, &wsadata);
}
}

int ossock_ioctl(int fd, c_ulong request, void* arg)
{
version (Windows) {
    int ret = ioctlsocket(fd, request, arg);
    if (ret == SOCKET_ERROR)
        ret = WSAGetLastError();
    return ret;
} else {
    return ioctl(fd, request,arg);
}
}

int ossock_close(int fd)
{
version (Windows) {
    int ret = closesocket(fd);
    if (ret == SOCKET_ERROR)
        errno = WSAGetLastError();
    return ret;
} else {
    return close(fd);
}
}

int ossock_wouldblock(int err)
{
version (Windows) {
    return ((err == EAGAIN) || (err == WSAEWOULDBLOCK));
} else {
    return ((err == EAGAIN) || (err == EWOULDBLOCK));
}
}

bool ossock_eintr(int err)
{
version (Windows) {
    return (err == WSAEINTR);
} else {
    return (err == EINTR);
}
}

int ossock_errno()
{
version (Windows) {
    return WSAGetLastError();
} else {
    return errno;
}
}
