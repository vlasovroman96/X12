module render.c;
@nogc nothrow:
extern(C): __gshared:
/*
 *
 * Copyright © 2000 SuSE, Inc.
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation, and that the name of SuSE not be used in advertising or
 * publicity pertaining to distribution of the software without specific,
 * written prior permission.  SuSE makes no representations about the
 * suitability of this software for any purpose.  It is provided "as is"
 * without express or implied warranty.
 *
 * SuSE DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING ALL
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT SHALL SuSE
 * BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
 * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * Author:  Keith Packard, SuSE, Inc.
 */

import build.dix_config;

import core.stdc.stdint;
import deimos.X11.X;
import deimos.X11.Xproto;
import deimos.X11.extensions.render;
import deimos.X11.extensions.renderproto;
import deimos.X11.Xfuncproto;

import dix.colormap_priv;
import dix.cursor_priv;
import dix.dix_priv;
import dix.request_priv;
import dix.screenint_priv;
import dix.server_priv;
import miext.extinit_priv;
import os.osdep;
import Xext.panoramiX;
import Xext.panoramiXsrv;

import misc;
import os;
import dixstruct;
import include.resource;
import include.scrnintstr;
import include.windowstr;
import include.pixmapstr;
import include.extnsionst;
import include.servermd;
import picturestr_priv;
import glyphstr_priv;
import include.cursorstr;
import xace;
import include.protocol_versions;

Bool noRenderExtension = FALSE;
Bool usePanoramiX = FALSE;

































int RenderErrBase;
private DevPrivateKeyRec RenderClientPrivateKeyRec;

enum RenderClientPrivateKey = (&RenderClientPrivateKeyRec );

struct _RenderClient {
    int major_version;
    int minor_version;
}alias RenderClientRec = _RenderClient;
alias RenderClientPtr = _RenderClient*;

enum string GetRenderClient(string pClient) = `(cast(RenderClientPtr)dixLookupPrivate(&(` ~ pClient ~ `).devPrivates, RenderClientPrivateKey))`;

version (XINERAMA) {
RESTYPE XRT_PICTURE;
} /* XINERAMA */

void RenderExtensionInit()
{
    ExtensionEntry* extEntry = void;

    if (!PictureType)
        return;
    if (!PictureFinishInit())
        return;
    if (!dixRegisterPrivateKey
        (&RenderClientPrivateKeyRec, PRIVATE_CLIENT, RenderClientRec.sizeof))
        return;

    extEntry = AddExtension(RENDER_NAME, 0, RenderNumberErrors,
                            ProcRenderDispatch, ProcRenderDispatch,
                            null, StandardMinorOpcode);
    if (!extEntry)
        return;
    RenderErrBase = extEntry.errorBase;
version (XINERAMA) {
    if (XRT_PICTURE)
        SetResourceTypeErrorValue(XRT_PICTURE, RenderErrBase + BadPicture);
} /* XINERAMA */
    SetResourceTypeErrorValue(PictureType, RenderErrBase + BadPicture);
    SetResourceTypeErrorValue(PictFormatType, RenderErrBase + BadPictFormat);
    SetResourceTypeErrorValue(GlyphSetType, RenderErrBase + BadGlyphSet);
}

private int ProcRenderQueryVersion(ClientPtr client)
{
    RenderClientPtr pRenderClient = mixin(GetRenderClient!(`client`));

    REQUEST(xRenderQueryVersionReq);
    REQUEST_SIZE_MATCH(xRenderQueryVersionReq);

    if (client.swapped) {
        swapl(&stuff.majorVersion);
        swapl(&stuff.minorVersion);
    }

    pRenderClient.major_version = stuff.majorVersion;
    pRenderClient.minor_version = stuff.minorVersion;

    xRenderQueryVersionReply reply = {
        majorVersion: SERVER_RENDER_MAJOR_VERSION,
        minorVersion: SERVER_RENDER_MINOR_VERSION
    };

    if ((stuff.majorVersion * 1000 + stuff.minorVersion) <
        (SERVER_RENDER_MAJOR_VERSION * 1000 + SERVER_RENDER_MINOR_VERSION)) {
        reply.majorVersion = stuff.majorVersion;
        reply.minorVersion = stuff.minorVersion;
    }

    if (client.swapped) {
        swapl(&reply.majorVersion);
        swapl(&reply.minorVersion);
    }
    return X_SEND_REPLY_SIMPLE(client, reply);
}

private VisualPtr findVisual(ScreenPtr pScreen, VisualID vid)
{
    VisualPtr pVisual = void;
    int v = void;

    for (v = 0; v < pScreen.numVisuals; v++) {
        pVisual = pScreen.visuals + v;
        if (pVisual.vid == vid)
            return pVisual;
    }
    return 0;
}

private int ProcRenderQueryPictFormats(ClientPtr client)
{
    RenderClientPtr pRenderClient = mixin(GetRenderClient!(`client`));
    xPictScreen* pictScreen = void;
    xPictDepth* pictDepth = void;
    xPictVisual* pictVisual = void;
    CARD32* pictSubpixel = void;
    VisualPtr pVisual = void;
    DepthPtr pDepth = void;
    int v = void, d = void;
    int nformat = void;
    int ndepth = void;
    int nvisual = void;
    int rlength = void;
    int numScreens = void;
    int numSubpixel = void;

/*    REQUEST(xRenderQueryPictFormatsReq); */

    REQUEST_SIZE_MATCH(xRenderQueryPictFormatsReq);

version (XINERAMA) {
    if (noPanoramiXExtension)
        numScreens = screenInfo.numScreens;
    else
        numScreens = (cast(xConnSetup*) ConnectionInfo).numRoots;
} else {
    numScreens = screenInfo.numScreens;
} /* XINERAMA */
    ndepth = nformat = nvisual = 0;
    for (uint walkScreenIdx = 0; walkScreenIdx < numScreens; walkScreenIdx++) {
        ScreenPtr walkScreen = screenInfo.screens[walkScreenIdx];
        for (d = 0; d < walkScreen.numDepths; d++) {
            pDepth = walkScreen.allowedDepths + d;
            ++ndepth;

            for (v = 0; v < pDepth.numVids; v++) {
                pVisual = findVisual(walkScreen, pDepth.vids[v]);
                if (pVisual &&
                    PictureMatchVisual(walkScreen, pDepth.depth, pVisual))
                    ++nvisual;
            }
        }
        PictureScreenPtr ps = GetPictureScreenIfSet(walkScreen);
        if (ps)
            nformat += ps.nformats;
    }
    if (pRenderClient.major_version == 0 && pRenderClient.minor_version < 6)
        numSubpixel = 0;
    else
        numSubpixel = numScreens;

    rlength = (nformat * (cast(xPictFormInfo) +
               numScreens * (cast(xPictScreen) +
               ndepth * (cast(xPictDepth) +
               nvisual * (cast(xPictVisual) + numSubpixel * CARD32.sizeof).sizeof).sizeof).sizeof).sizeof);

    x_rpcbuf_t rpcbuf = { swapped: client.swapped, err_clear: TRUE };

    xPictFormInfo* pictForm = x_rpcbuf_reserve(&rpcbuf, rlength);
    if (!pictForm)
        return BadAlloc;

    for (uint walkScreenIdx = 0; walkScreenIdx < numScreens; walkScreenIdx++) {
        ScreenPtr walkScreen = screenInfo.screens[walkScreenIdx];
        PictureScreenPtr ps = GetPictureScreenIfSet(walkScreen);
        if (ps) {
            size_t idx = void;
            PictFormatPtr pFormat = void;
            for (idx = 0, pFormat = ps.formats;
                 idx < ps.nformats; idx++, pFormat++) {
                pictForm.id = pFormat.id;
                pictForm.type = pFormat.type;
                pictForm.depth = pFormat.depth;
                pictForm.direct.red = pFormat.direct.red;
                pictForm.direct.redMask = pFormat.direct.redMask;
                pictForm.direct.green = pFormat.direct.green;
                pictForm.direct.greenMask = pFormat.direct.greenMask;
                pictForm.direct.blue = pFormat.direct.blue;
                pictForm.direct.blueMask = pFormat.direct.blueMask;
                pictForm.direct.alpha = pFormat.direct.alpha;
                pictForm.direct.alphaMask = pFormat.direct.alphaMask;
                if (pFormat.type == PictTypeIndexed &&
                    pFormat.index.pColormap)
                    pictForm.colormap = pFormat.index.pColormap.mid;
                else
                    pictForm.colormap = None;
                if (client.swapped) {
                    swapl(&pictForm.id);
                    swaps(&pictForm.direct.red);
                    swaps(&pictForm.direct.redMask);
                    swaps(&pictForm.direct.green);
                    swaps(&pictForm.direct.greenMask);
                    swaps(&pictForm.direct.blue);
                    swaps(&pictForm.direct.blueMask);
                    swaps(&pictForm.direct.alpha);
                    swaps(&pictForm.direct.alphaMask);
                    swapl(&pictForm.colormap);
                }
                pictForm++;
            }
        }
    }

    pictScreen = cast(xPictScreen*) pictForm;
    for (uint walkScreenIdx = 0; walkScreenIdx < numScreens; walkScreenIdx++) {
        ScreenPtr walkScreen = screenInfo.screens[walkScreenIdx];
        pictDepth = cast(xPictDepth*) (pictScreen + 1);
        pictScreen.nDepth = 0; /* counting in here */
        for (d = 0; d < walkScreen.numDepths; d++) {
            pictVisual = cast(xPictVisual*) (pictDepth + 1);
            pDepth = walkScreen.allowedDepths + d;
            pictDepth.nPictVisuals = 0; /* counting in here */
            for (v = 0; v < pDepth.numVids; v++) {
                PictFormatPtr pFormat = void;

                pVisual = findVisual(walkScreen, pDepth.vids[v]);
                if (pVisual && (pFormat = PictureMatchVisual(walkScreen,
                                                             pDepth.depth,
                                                             pVisual))) {
                    pictVisual.visual = pVisual.vid;
                    pictVisual.format = pFormat.id;
                    if (client.swapped) {
                        swapl(&pictVisual.visual);
                        swapl(&pictVisual.format);
                    }
                    pictVisual++;
                    pictDepth.nPictVisuals++;
                }
            }
            pictDepth.depth = pDepth.depth;
            if (client.swapped) {
                swaps(&pictDepth.nPictVisuals);
            }
            pictScreen.nDepth++;
            pictDepth = cast(xPictDepth*) pictVisual;
        }
        PictureScreenPtr ps = GetPictureScreenIfSet(walkScreen);
        if (ps)
            pictScreen.fallback = ps.fallback.id;
        else
            pictScreen.fallback = 0;
        if (client.swapped) {
            swapl(&pictScreen.nDepth);
            swapl(&pictScreen.fallback);
        }
        pictScreen = cast(xPictScreen*) pictDepth;
    }
    pictSubpixel = cast(CARD32*) pictScreen;

    for (uint walkScreenIdx = 0; walkScreenIdx < numSubpixel; walkScreenIdx++) {
        ScreenPtr walkScreen = screenInfo.screens[walkScreenIdx];
        PictureScreenPtr ps = GetPictureScreenIfSet(walkScreen);
        if (ps)
            *pictSubpixel = ps.subpixel;
        else
            *pictSubpixel = SubPixelUnknown;
        if (client.swapped) {
            swapl(pictSubpixel);
        }
        ++pictSubpixel;
    }

    xRenderQueryPictFormatsReply reply = {
        numFormats: nformat,
        numScreens: numScreens,
        numDepths: ndepth,
        numVisuals: nvisual,
        numSubpixel: numSubpixel,
    };

    if (client.swapped) {
        swapl(&reply.numFormats);
        swapl(&reply.numScreens);
        swapl(&reply.numDepths);
        swapl(&reply.numVisuals);
        swapl(&reply.numSubpixel);
    }

    return X_SEND_REPLY_WITH_RPCBUF(client, reply, rpcbuf);
}

private int ProcRenderQueryPictIndexValues(ClientPtr client)
{
    PictFormatPtr pFormat = void;
    int rc = void;

    REQUEST(xRenderQueryPictIndexValuesReq);
    REQUEST_AT_LEAST_SIZE(xRenderQueryPictIndexValuesReq);

    if (client.swapped)
        swapl(&stuff.format);

    rc = dixLookupResourceByType(cast(void**) &pFormat, stuff.format,
                                 PictFormatType, client, DixReadAccess);
    if (rc != Success)
        return rc;

    if (pFormat.type != PictTypeIndexed) {
        client.errorValue = stuff.format;
        return BadMatch;
    }

    x_rpcbuf_t rpcbuf = { swapped: client.swapped, err_clear: TRUE };
    for (int i = 0; i < pFormat.index.nvalues; i++) {
        /* write xIndexValue */
        xIndexValue* iv = &(pFormat.index.pValues[i]);
        x_rpcbuf_write_CARD32(&rpcbuf, iv.pixel);
        x_rpcbuf_write_CARD16(&rpcbuf, iv.red);
        x_rpcbuf_write_CARD16(&rpcbuf, iv.green);
        x_rpcbuf_write_CARD16(&rpcbuf, iv.blue);
        x_rpcbuf_write_CARD16(&rpcbuf, iv.alpha);
    }

    xRenderQueryPictIndexValuesReply reply = {
        numIndexValues: pFormat.index.nvalues
    };

    if (client.swapped) {
        swapl(&reply.numIndexValues);
    }

    return X_SEND_REPLY_WITH_RPCBUF(client, reply, rpcbuf);
}

private int SingleRenderCreatePicture(ClientPtr client, xRenderCreatePictureReq* stuff)
{
    PicturePtr pPicture = void;
    DrawablePtr pDrawable = void;
    PictFormatPtr pFormat = void;
    int len = void, error = void, rc = void;

    LEGAL_NEW_RESOURCE(stuff.pid, client);
    rc = dixLookupDrawable(&pDrawable, stuff.drawable, client, 0,
                           DixReadAccess | DixAddAccess);
    if (rc != Success)
        return rc;

    rc = dixLookupResourceByType(cast(void**) &pFormat, stuff.format,
                                 PictFormatType, client, DixReadAccess);
    if (rc != Success)
        return rc;

    if (pFormat.depth != pDrawable.depth)
        return BadMatch;
    len = client.req_len - bytes_to_int32(xRenderCreatePictureReq.sizeof);
    if (Ones(stuff.mask) != len)
        return BadLength;

    pPicture = CreatePicture(stuff.pid,
                             pDrawable,
                             pFormat,
                             stuff.mask, cast(XID*) (stuff + 1), client, &error);
    if (!pPicture)
        return error;
    if (!AddResource(stuff.pid, PictureType, cast(void*) pPicture))
        return BadAlloc;
    return Success;
}

private int SingleRenderChangePicture(ClientPtr client, xRenderChangePictureReq* stuff, Picture pictID)
{
    PicturePtr pPicture = void;

    int len = void;

    VERIFY_PICTURE(pPicture, pictID, client, DixSetAttrAccess);

    len = client.req_len - bytes_to_int32(xRenderChangePictureReq.sizeof);
    if (Ones(stuff.mask) != len)
        return BadLength;

    return ChangePicture(pPicture, stuff.mask, cast(XID*) (stuff + 1),
                         cast(DevUnion*) 0, client);
}

private int SingleRenderSetPictureClipRectangles(ClientPtr client, xRenderSetPictureClipRectanglesReq* stuff, Picture pictID)
{
    PicturePtr pPicture = void;
    int nr = void;

    VERIFY_PICTURE(pPicture, pictID, client, DixSetAttrAccess);
    if (!pPicture.pDrawable)
        return RenderErrBase + BadPicture;

    nr = (client.req_len << 2) - xRenderSetPictureClipRectanglesReq.sizeof;
    if (nr & 4)
        return BadLength;
    nr >>= 3;
    return SetPictureClipRects(pPicture,
                               stuff.xOrigin, stuff.yOrigin,
                               nr, cast(xRectangle*) &stuff[1]);
}

private int SingleRenderFreePicture(ClientPtr client)
{
    PicturePtr pPicture = void;

    REQUEST(xRenderFreePictureReq);

    VERIFY_PICTURE(pPicture, stuff.picture, client, DixDestroyAccess);
    FreeResource(stuff.picture, X11_RESTYPE_NONE);
    return Success;
}

private Bool PictOpValid(CARD8 op)
{
    if ( /*PictOpMinimum <= op && */ op <= PictOpMaximum)
        return TRUE;
    if (PictOpDisjointMinimum <= op && op <= PictOpDisjointMaximum)
        return TRUE;
    if (PictOpConjointMinimum <= op && op <= PictOpConjointMaximum)
        return TRUE;
    if (PictOpBlendMinimum <= op && op <= PictOpBlendMaximum)
        return TRUE;
    return FALSE;
}

private int SingleRenderComposite(ClientPtr client, xRenderCompositeReq* stuff)
{
    PicturePtr pSrc = void, pMask = void, pDst = void;

    if (!PictOpValid(stuff.op)) {
        client.errorValue = stuff.op;
        return BadValue;
    }
    VERIFY_PICTURE(pDst, stuff.dst, client, DixWriteAccess);
    if (!pDst.pDrawable)
        return BadDrawable;
    VERIFY_PICTURE(pSrc, stuff.src, client, DixReadAccess);
    VERIFY_ALPHA(pMask, stuff.mask, client, DixReadAccess);
    if ((pSrc.pDrawable &&
         pSrc.pDrawable.pScreen != pDst.pDrawable.pScreen) || (pMask &&
                                                                   pMask.
                                                                   pDrawable &&
                                                                   pDst.
                                                                   pDrawable.
                                                                   pScreen !=
                                                                   pMask.
                                                                   pDrawable.
                                                                   pScreen))
        return BadMatch;
    CompositePicture(stuff.op,
                     pSrc,
                     pMask,
                     pDst,
                     stuff.xSrc,
                     stuff.ySrc,
                     stuff.xMask,
                     stuff.yMask,
                     stuff.xDst, stuff.yDst, stuff.width, stuff.height);
    return Success;
}

private int SingleRenderTrapezoids(ClientPtr client, xRenderTrapezoidsReq* stuff)
{
    int rc = void, ntraps = void;
    PicturePtr pSrc = void, pDst = void;
    PictFormatPtr pFormat = void;

    if (!PictOpValid(stuff.op)) {
        client.errorValue = stuff.op;
        return BadValue;
    }
    VERIFY_PICTURE(pSrc, stuff.src, client, DixReadAccess);
    VERIFY_PICTURE(pDst, stuff.dst, client, DixWriteAccess);
    if (!pDst.pDrawable)
        return BadDrawable;
    if (pSrc.pDrawable && pSrc.pDrawable.pScreen != pDst.pDrawable.pScreen)
        return BadMatch;
    if (stuff.maskFormat) {
        rc = dixLookupResourceByType(cast(void**) &pFormat, stuff.maskFormat,
                                     PictFormatType, client, DixReadAccess);
        if (rc != Success)
            return rc;
    }
    else
        pFormat = 0;
    ntraps = (client.req_len << 2) - xRenderTrapezoidsReq.sizeof;
    if (ntraps % xTrapezoid.sizeof)
        return BadLength;
    ntraps /= xTrapezoid.sizeof;
    if (ntraps)
        CompositeTrapezoids(stuff.op, pSrc, pDst, pFormat,
                            stuff.xSrc, stuff.ySrc,
                            ntraps, cast(xTrapezoid*) &stuff[1]);
    return Success;
}

private int SingleRenderTriangles(ClientPtr client, xRenderTrianglesReq* stuff)
{
    int rc = void, ntris = void;
    PicturePtr pSrc = void, pDst = void;
    PictFormatPtr pFormat = void;

    if (!PictOpValid(stuff.op)) {
        client.errorValue = stuff.op;
        return BadValue;
    }
    VERIFY_PICTURE(pSrc, stuff.src, client, DixReadAccess);
    VERIFY_PICTURE(pDst, stuff.dst, client, DixWriteAccess);
    if (!pDst.pDrawable)
        return BadDrawable;
    if (pSrc.pDrawable && pSrc.pDrawable.pScreen != pDst.pDrawable.pScreen)
        return BadMatch;
    if (stuff.maskFormat) {
        rc = dixLookupResourceByType(cast(void**) &pFormat, stuff.maskFormat,
                                     PictFormatType, client, DixReadAccess);
        if (rc != Success)
            return rc;
    }
    else
        pFormat = 0;
    ntris = (client.req_len << 2) - xRenderTrianglesReq.sizeof;
    if (ntris % xTriangle.sizeof)
        return BadLength;
    ntris /= xTriangle.sizeof;
    if (ntris)
        CompositeTriangles(stuff.op, pSrc, pDst, pFormat,
                           stuff.xSrc, stuff.ySrc,
                           ntris, cast(xTriangle*) &stuff[1]);
    return Success;
}

private int SingleRenderTriStrip(ClientPtr client, xRenderTriStripReq* stuff)
{
    int rc = void, npoints = void;
    PicturePtr pSrc = void, pDst = void;
    PictFormatPtr pFormat = void;

    if (!PictOpValid(stuff.op)) {
        client.errorValue = stuff.op;
        return BadValue;
    }
    VERIFY_PICTURE(pSrc, stuff.src, client, DixReadAccess);
    VERIFY_PICTURE(pDst, stuff.dst, client, DixWriteAccess);
    if (!pDst.pDrawable)
        return BadDrawable;
    if (pSrc.pDrawable && pSrc.pDrawable.pScreen != pDst.pDrawable.pScreen)
        return BadMatch;
    if (stuff.maskFormat) {
        rc = dixLookupResourceByType(cast(void**) &pFormat, stuff.maskFormat,
                                     PictFormatType, client, DixReadAccess);
        if (rc != Success)
            return rc;
    }
    else
        pFormat = 0;
    npoints = ((client.req_len << 2) - xRenderTriStripReq.sizeof);
    if (npoints & 4)
        return BadLength;
    npoints >>= 3;
    if (npoints >= 3)
        CompositeTriStrip(stuff.op, pSrc, pDst, pFormat,
                          stuff.xSrc, stuff.ySrc,
                          npoints, cast(xPointFixed*) &stuff[1]);
    return Success;
}

private int SingleRenderTriFan(ClientPtr client, xRenderTriFanReq* stuff)
{
    int rc = void, npoints = void;
    PicturePtr pSrc = void, pDst = void;
    PictFormatPtr pFormat = void;

    if (!PictOpValid(stuff.op)) {
        client.errorValue = stuff.op;
        return BadValue;
    }
    VERIFY_PICTURE(pSrc, stuff.src, client, DixReadAccess);
    VERIFY_PICTURE(pDst, stuff.dst, client, DixWriteAccess);
    if (!pDst.pDrawable)
        return BadDrawable;
    if (pSrc.pDrawable && pSrc.pDrawable.pScreen != pDst.pDrawable.pScreen)
        return BadMatch;
    if (stuff.maskFormat) {
        rc = dixLookupResourceByType(cast(void**) &pFormat, stuff.maskFormat,
                                     PictFormatType, client, DixReadAccess);
        if (rc != Success)
            return rc;
    }
    else
        pFormat = 0;
    npoints = ((client.req_len << 2) - xRenderTriStripReq.sizeof);
    if (npoints & 4)
        return BadLength;
    npoints >>= 3;
    if (npoints >= 3)
        CompositeTriFan(stuff.op, pSrc, pDst, pFormat,
                        stuff.xSrc, stuff.ySrc,
                        npoints, cast(xPointFixed*) &stuff[1]);
    return Success;
}

private int ProcRenderCreateGlyphSet(ClientPtr client)
{
    GlyphSetPtr glyphSet = void;
    PictFormatPtr format = void;
    int rc = void, f = void;

    REQUEST(xRenderCreateGlyphSetReq);
    REQUEST_SIZE_MATCH(xRenderCreateGlyphSetReq);

    if (client.swapped) {
        swapl(&stuff.gsid);
        swapl(&stuff.format);
    }

    LEGAL_NEW_RESOURCE(stuff.gsid, client);
    rc = dixLookupResourceByType(cast(void**) &format, stuff.format,
                                 PictFormatType, client, DixReadAccess);
    if (rc != Success)
        return rc;

    switch (format.depth) {
    case 1:
        f = GlyphFormat1;
        break;
    case 4:
        f = GlyphFormat4;
        break;
    case 8:
        f = GlyphFormat8;
        break;
    case 16:
        f = GlyphFormat16;
        break;
    case 32:
        f = GlyphFormat32;
        break;
    default:
        return BadMatch;
    }
    if (format.type != PictTypeDirect)
        return BadMatch;
    glyphSet = AllocateGlyphSet(f, format);
    if (!glyphSet)
        return BadAlloc;
    /* security creation/labeling check */
    rc = XaceHookResourceAccess(client, stuff.gsid, GlyphSetType,
                  glyphSet, X11_RESTYPE_NONE, null, DixCreateAccess);
    if (rc != Success)
        return rc;
    if (!AddResource(stuff.gsid, GlyphSetType, cast(void*) glyphSet))
        return BadAlloc;
    return Success;
}

private int ProcRenderReferenceGlyphSet(ClientPtr client)
{
    GlyphSetPtr glyphSet = void;
    int rc = void;

    REQUEST(xRenderReferenceGlyphSetReq);
    REQUEST_SIZE_MATCH(xRenderReferenceGlyphSetReq);

    if (client.swapped) {
        swapl(&stuff.gsid);
        swapl(&stuff.existing);
    }

    LEGAL_NEW_RESOURCE(stuff.gsid, client);

    rc = dixLookupResourceByType(cast(void**) &glyphSet, stuff.existing,
                                 GlyphSetType, client, DixGetAttrAccess);
    if (rc != Success) {
        client.errorValue = stuff.existing;
        return rc;
    }
    glyphSet.refcnt++;
    if (!AddResource(stuff.gsid, GlyphSetType, cast(void*) glyphSet))
        return BadAlloc;
    return Success;
}

enum NLOCALDELTA =	64;
enum NLOCALGLYPH =	256;

private int ProcRenderFreeGlyphSet(ClientPtr client)
{
    GlyphSetPtr glyphSet = void;
    int rc = void;

    REQUEST(xRenderFreeGlyphSetReq);
    REQUEST_SIZE_MATCH(xRenderFreeGlyphSetReq);

    if (client.swapped)
        swapl(&stuff.glyphset);

    rc = dixLookupResourceByType(cast(void**) &glyphSet, stuff.glyphset,
                                 GlyphSetType, client, DixDestroyAccess);
    if (rc != Success) {
        client.errorValue = stuff.glyphset;
        return rc;
    }
    FreeResource(stuff.glyphset, X11_RESTYPE_NONE);
    return Success;
}

struct _GlyphNew {
    Glyph id;
    GlyphPtr glyph;
    Bool found;
    ubyte[20] sha1;
}alias GlyphNewRec = _GlyphNew;
alias GlyphNewPtr = _GlyphNew*;

enum string NeedsComponent(string f) = `(PIXMAN_FORMAT_A(` ~ f ~ `) != 0 && PIXMAN_FORMAT_RGB(` ~ f ~ `) != 0)`;

private int ProcRenderAddGlyphs(ClientPtr client)
{
    REQUEST(xRenderAddGlyphsReq);
    REQUEST_AT_LEAST_SIZE(xRenderAddGlyphsReq);

    if (client.swapped) {
        swapl(&stuff.glyphset);
        swapl(&stuff.nglyphs);
        if (stuff.nglyphs & 0xe0000000)
            return BadLength;
        void* end = cast(CARD8*) stuff + (client.req_len << 2);
        CARD32* gids = cast(CARD32*) (stuff + 1);
        xGlyphInfo* gi = cast(xGlyphInfo*) (gids + stuff.nglyphs);
        if (cast(char*) end - cast(char*) (gids + stuff.nglyphs) < 0)
            return BadLength;
        if (cast(char*) end - cast(char*) (gi + stuff.nglyphs) < 0)
            return BadLength;
        for (int i = 0; i < stuff.nglyphs; i++) {
            swapl(&gids[i]);
            swaps(&gi[i].width);
            swaps(&gi[i].height);
            swaps(&gi[i].x);
            swaps(&gi[i].y);
            swaps(&gi[i].xOff);
            swaps(&gi[i].yOff);
        }
    }

    GlyphSetPtr glyphSet = void;

    GlyphNewRec[NLOCALGLYPH] glyphsLocal = void;
    GlyphNewPtr glyphsBase = void, glyphs = void, glyph_new = void;
    int remain = void, nglyphs = void;
    CARD32* gids = void;
    xGlyphInfo* gi = void;
    CARD8* bits = void;
    uint size = void;
    int err = void;
    int i = void;
    CARD32 component_alpha = void;

    REQUEST_AT_LEAST_SIZE(xRenderAddGlyphsReq);
    err =
        dixLookupResourceByType(cast(void**) &glyphSet, stuff.glyphset,
                                GlyphSetType, client, DixAddAccess);
    if (err != Success) {
        client.errorValue = stuff.glyphset;
        return err;
    }

    err = BadAlloc;
    nglyphs = stuff.nglyphs;
    if (nglyphs > UINT32_MAX / GlyphNewRec.sizeof)
        return BadAlloc;

    component_alpha = mixin(NeedsComponent!(`glyphSet.format.format`));

    if (nglyphs <= NLOCALGLYPH) {
        memset(glyphsLocal.ptr, 0, glyphsLocal.sizeof);
        glyphsBase = glyphsLocal;
    }
    else {
        glyphsBase = cast(GlyphNewPtr) calloc(nglyphs, GlyphNewRec.sizeof);
        if (!glyphsBase)
            return BadAlloc;
    }

    remain = (client.req_len << 2) - xRenderAddGlyphsReq.sizeof;

    glyphs = glyphsBase;

    gids = cast(CARD32*) (stuff + 1);
    gi = cast(xGlyphInfo*) (gids + nglyphs);
    bits = cast(CARD8*) (gi + nglyphs);
    remain -= (((CARD32) + xGlyphInfo.sizeof).sizeof) * nglyphs;

    /* protect against bad nglyphs */
    if (gi < (cast(xGlyphInfo*) stuff) ||
        gi > (cast(xGlyphInfo*) (cast(CARD32*) stuff + client.req_len)) ||
        bits < (cast(CARD8*) stuff) ||
        bits > (cast(CARD8*) (cast(CARD32*) stuff + client.req_len))) {
        err = BadLength;
        goto bail;
    }

    for (i = 0; i < nglyphs; i++) {
        size_t padded_width = void;

        glyph_new = &glyphs[i];

        padded_width = PixmapBytePad(gi[i].width, glyphSet.format.depth);

        if (gi[i].height &&
            padded_width > (UINT32_MAX - GlyphRec.sizeof) / gi[i].height)
            break;

        size = gi[i].height * padded_width;
        if (remain < size)
            break;

        err = HashGlyph(&gi[i], bits, size, glyph_new.sha1);
        if (err)
            goto bail;

        glyph_new.glyph = FindGlyphByHash(glyph_new.sha1, glyphSet.fdepth);

        if (glyph_new.glyph && glyph_new.glyph != DeletedGlyph) {
            glyph_new.found = TRUE;
            ++glyph_new.glyph.refcnt;
        }
        else {
            GlyphPtr glyph = void;

            glyph_new.found = FALSE;
            glyph_new.glyph = glyph = AllocateGlyph(&gi[i], glyphSet.fdepth);
            if (!glyph) {
                err = BadAlloc;
                goto bail;
            }

            DIX_FOR_EACH_SCREEN({
                int width = gi[i].width;
                int height = gi[i].height;
                int depth = glyphSet.format.depth;
                int error = void;

                /* Skip work if it's invisibly small anyway */
                if (!width || !height)
                    break;

                PixmapPtr pSrcPix = GetScratchPixmapHeader(walkScreen,
                                                 width, height,
                                                 depth, depth, -1, bits);
                if (!pSrcPix) {
                    err = BadAlloc;
                    goto bail;
                }

                PicturePtr pSrc = CreatePicture(0, &pSrcPix.drawable,
                                     glyphSet.format, 0, null,
                                     serverClient, &error);
                if (!pSrc) {
                    err = BadAlloc;
                    FreeScratchPixmapHeader(pSrcPix);
                    goto bail;
                }

                PixmapPtr pDstPix = walkScreen.CreatePixmap(walkScreen,
                                                   width, height, depth,
                                                   CREATE_PIXMAP_USAGE_GLYPH_PICTURE);

                if (!pDstPix) {
                    err = BadAlloc;
                    FreeScratchPixmapHeader(pSrcPix);
                    FreePicture(cast(void*) pSrc, 0);
                    goto bail;
                }

                PicturePtr pDst = CreatePicture(0, &pDstPix.drawable,
                                  glyphSet.format,
                                  CPComponentAlpha, &component_alpha,
                                  serverClient, &error);
                SetGlyphPicture(glyph, walkScreen, pDst);

                /* The picture takes a reference to the pixmap, so we
                   drop ours. */
                dixDestroyPixmap(pDstPix, 0);
                pDstPix = null;

                if (!pDst) {
                    err = BadAlloc;
                    FreePicture(cast(void*) pSrc, 0);
                    FreeScratchPixmapHeader(pSrcPix);
                    goto bail;
                }

                CompositePicture(PictOpSrc,
                                 pSrc,
                                 None, pDst, 0, 0, 0, 0, 0, 0, width, height);

                FreePicture(cast(void*) pSrc, 0);
                FreeScratchPixmapHeader(pSrcPix);
            });

            memcpy(glyph_new.glyph.sha1, glyph_new.sha1, 20);
        }

        glyph_new.id = gids[i];

        if (size & 3)
            size += 4 - (size & 3);
        bits += size;
        remain -= size;
    }
    if (remain || i < nglyphs) {
        err = BadLength;
        goto bail;
    }
    if (!ResizeGlyphSet(glyphSet, nglyphs)) {
        err = BadAlloc;
        goto bail;
    }
    for (i = 0; i < nglyphs; i++) {
        AddGlyph(glyphSet, glyphs[i].glyph, glyphs[i].id);
        FreeGlyph(glyphs[i].glyph, glyphSet.fdepth);
    }

    if (glyphsBase != glyphsLocal.ptr)
        free(glyphsBase);
    return Success;
 bail:
    for (i = 0; i < nglyphs; i++) {
        if (glyphs[i].glyph) {
            --glyphs[i].glyph.refcnt;
            if (!glyphs[i].found)
                free(glyphs[i].glyph);
        }
    }
    if (glyphsBase != glyphsLocal.ptr)
        free(glyphsBase);
    return err;
}

private int ProcRenderFreeGlyphs(ClientPtr client)
{
    REQUEST(xRenderFreeGlyphsReq);
    REQUEST_AT_LEAST_SIZE(xRenderFreeGlyphsReq);

    if (client.swapped) {
        swapl(&stuff.glyphset);
        SwapRestL(stuff);
    }

    GlyphSetPtr glyphSet = void;
    int rc = void, nglyph = void;
    CARD32* gids = void;
    CARD32 glyph = void;

    rc = dixLookupResourceByType(cast(void**) &glyphSet, stuff.glyphset,
                                 GlyphSetType, client, DixRemoveAccess);
    if (rc != Success) {
        client.errorValue = stuff.glyphset;
        return rc;
    }
    nglyph =
        bytes_to_int32((client.req_len << 2) - xRenderFreeGlyphsReq.sizeof);
    gids = cast(CARD32*) (stuff + 1);
    while (nglyph-- > 0) {
        glyph = *gids++;
        if (!DeleteGlyph(glyphSet, glyph)) {
            client.errorValue = glyph;
            return RenderErrBase + BadGlyph;
        }
    }
    return Success;
}

private int SingleRenderCompositeGlyphs(ClientPtr client, xRenderCompositeGlyphsReq* stuff)
{
    GlyphSetPtr glyphSet = void;
    GlyphSet gs = void;
    PicturePtr pSrc = void, pDst = void;
    PictFormatPtr pFormat = void;
    GlyphListRec[NLOCALDELTA] listsLocal = void;
    GlyphListPtr lists = void, listsBase = void;
    GlyphPtr[NLOCALGLYPH] glyphsLocal = void;
    Glyph glyph = void;
    GlyphPtr* glyphs = void, glyphsBase = void;
    xGlyphElt* elt = void;
    CARD8* buffer = void, end = void;
    int nglyph = void;
    int nlist = void;
    int space = void;
    int size = void;
    int rc = void, n = void;

    switch (stuff.renderReqType) {
    default:
        size = 1;
        break;
    case X_RenderCompositeGlyphs16:
        size = 2;
        break;
    case X_RenderCompositeGlyphs32:
        size = 4;
        break;
    }

    if (!PictOpValid(stuff.op)) {
        client.errorValue = stuff.op;
        return BadValue;
    }
    VERIFY_PICTURE(pSrc, stuff.src, client, DixReadAccess);
    VERIFY_PICTURE(pDst, stuff.dst, client, DixWriteAccess);
    if (!pDst.pDrawable)
        return BadDrawable;
    if (pSrc.pDrawable && pSrc.pDrawable.pScreen != pDst.pDrawable.pScreen)
        return BadMatch;
    if (stuff.maskFormat) {
        rc = dixLookupResourceByType(cast(void**) &pFormat, stuff.maskFormat,
                                     PictFormatType, client, DixReadAccess);
        if (rc != Success)
            return rc;
    }
    else
        pFormat = 0;

    rc = dixLookupResourceByType(cast(void**) &glyphSet, stuff.glyphset,
                                 GlyphSetType, client, DixUseAccess);
    if (rc != Success)
        return rc;

    buffer = cast(CARD8*) (stuff + 1);
    end = cast(CARD8*) stuff + (client.req_len << 2);
    nglyph = 0;
    nlist = 0;
    while (buffer + xGlyphElt.sizeof < end) {
        elt = cast(xGlyphElt*) buffer;
        buffer += xGlyphElt.sizeof;

        if (elt.len == 0xff) {
            buffer += 4;
        }
        else {
            nlist++;
            nglyph += elt.len;
            space = size * elt.len;
            if (space & 3)
                space += 4 - (space & 3);
            buffer += space;
        }
    }
    if (nglyph <= NLOCALGLYPH)
        glyphsBase = glyphsLocal;
    else {
        glyphsBase = cast(GlyphPtr*) calloc(nglyph, GlyphPtr.sizeof);
        if (!glyphsBase)
            return BadAlloc;
    }
    if (nlist <= NLOCALDELTA)
        listsBase = listsLocal;
    else {
        listsBase = calloc(nlist, GlyphListRec.sizeof);
        if (!listsBase) {
            rc = BadAlloc;
            goto bail;
        }
    }
    buffer = cast(CARD8*) (stuff + 1);
    glyphs = glyphsBase;
    lists = listsBase;
    while (buffer + xGlyphElt.sizeof < end) {
        elt = cast(xGlyphElt*) buffer;
        buffer += xGlyphElt.sizeof;

        if (elt.len == 0xff) {
            if (buffer + GlyphSet.sizeof < end) {
                memcpy(&gs, buffer, GlyphSet.sizeof);
                rc = dixLookupResourceByType(cast(void**) &glyphSet, gs,
                                             GlyphSetType, client,
                                             DixUseAccess);
                if (rc != Success)
                    goto bail;
            }
            buffer += 4;
        }
        else {
            lists.xOff = elt.deltax;
            lists.yOff = elt.deltay;
            lists.format = glyphSet.format;
            lists.len = 0;
            n = elt.len;
            while (n--) {
                if (buffer + size <= end) {
                    switch (size) {
                    case 1:
                        glyph = *(cast(CARD8*) buffer);
                        break;
                    case 2:
                        glyph = *(cast(CARD16*) buffer);
                        break;
                    case 4:
                    default:
                        glyph = *(cast(CARD32*) buffer);
                        break;
                    }
                    if ((*glyphs = FindGlyph(glyphSet, glyph))) {
                        lists.len++;
                        glyphs++;
                    }
                }
                buffer += size;
            }
            space = size * elt.len;
            if (space & 3)
                buffer += 4 - (space & 3);
            lists++;
        }
    }
    if (buffer > end) {
        rc = BadLength;
        goto bail;
    }

    CompositeGlyphs(stuff.op,
                    pSrc,
                    pDst,
                    pFormat,
                    stuff.xSrc, stuff.ySrc, nlist, listsBase, glyphsBase);
    rc = Success;

 bail:
    if (glyphsBase != glyphsLocal.ptr)
        free(glyphsBase);
    if (listsBase != listsLocal.ptr)
        free(listsBase);
    return rc;
}

private int SingleRenderFillRectangles(ClientPtr client, xRenderFillRectanglesReq* stuff)
{
    PicturePtr pDst = void;
    int things = void;

    if (!PictOpValid(stuff.op)) {
        client.errorValue = stuff.op;
        return BadValue;
    }
    VERIFY_PICTURE(pDst, stuff.dst, client, DixWriteAccess);
    if (!pDst.pDrawable)
        return BadDrawable;

    things = (client.req_len << 2) - xRenderFillRectanglesReq.sizeof;
    if (things & 4)
        return BadLength;
    things >>= 3;

    CompositeRects(stuff.op,
                   pDst, &stuff.color, things, cast(xRectangle*) &stuff[1]);

    return Success;
}

private void RenderSetBit(ubyte* line, int x, int bit)
{
    ubyte mask = void;

    if (screenInfo.bitmapBitOrder == LSBFirst)
        mask = (1 << (x & 7));
    else
        mask = (0x80 >> (x & 7));
    /* XXX assumes byte order is host byte order */
    line += (x >> 3);
    if (bit)
        *line |= mask;
    else
        *line &= ~mask;
}

enum DITHER_DIM = 2;

private CARD32[DITHER_DIM][DITHER_DIM] orderedDither = [
    [1, 3,],
    [4, 2,],
];

enum DITHER_SIZE =  ((orderedDither.sizeof / orderedDither[0][0].sizeof) + 1);

private int ProcRenderCreateCursor(ClientPtr client)
{
    REQUEST(xRenderCreateCursorReq);
    REQUEST_SIZE_MATCH(xRenderCreateCursorReq);

    if (client.swapped) {
        swapl(&stuff.cid);
        swapl(&stuff.src);
        swaps(&stuff.x);
        swaps(&stuff.y);
    }

    PicturePtr pSrc = void;
    ScreenPtr pScreen = void;
    ushort width = void, height = void;
    CARD32* argb = void;
    ubyte* srcline = void;
    ubyte* mskline = void;
    int stride = void;
    int x = void, y = void;
    int nbytes_mono = void;
    CursorMetricRec cm = void;
    CursorPtr pCursor = void;
    CARD32[3] twocolor = void;
    int rc = void, ncolor = void;

    LEGAL_NEW_RESOURCE(stuff.cid, client);

    VERIFY_PICTURE(pSrc, stuff.src, client, DixReadAccess);
    if (!pSrc.pDrawable)
        return BadDrawable;
    pScreen = pSrc.pDrawable.pScreen;
    width = pSrc.pDrawable.width;
    height = pSrc.pDrawable.height;
    if (height && width > UINT32_MAX / (height * CARD32.sizeof))
        return BadAlloc;
    if (stuff.x > width || stuff.y > height)
        return BadMatch;

    CARD32* argbbits = cast(CARD32*) calloc(width * height, CARD32.sizeof);
    if (!argbbits)
        return BadAlloc;

    stride = BitmapBytePad(width);
    nbytes_mono = stride * height;

    ubyte* srcbits = cast(ubyte*) calloc(1, nbytes_mono);
    if (!srcbits) {
        free(argbbits);
        return BadAlloc;
    }

    ubyte* mskbits = cast(ubyte*) calloc(1, nbytes_mono);
    if (!mskbits) {
        free(argbbits);
        free(srcbits);
        return BadAlloc;
    }

    /* what kind of maniac creates a cursor from a window picture though */
    if (pSrc.pDrawable.type == DRAWABLE_WINDOW)
        pScreen.SourceValidate(pSrc.pDrawable, 0, 0, width, height,
                                IncludeInferiors);

    if (pSrc.format == PIXMAN_a8r8g8b8) {
        (*pScreen.GetImage) (pSrc.pDrawable,
                              0, 0, width, height, ZPixmap,
                              0xffffffff, cast(void*) argbbits);
    }
    else {
        PixmapPtr pPixmap = void;
        PicturePtr pPicture = void;
        PictFormatPtr pFormat = void;
        int error = void;

        pFormat = PictureMatchFormat(pScreen, 32, PIXMAN_a8r8g8b8);
        if (!pFormat) {
            free(argbbits);
            free(srcbits);
            free(mskbits);
            return BadImplementation;
        }
        pPixmap = (*pScreen.CreatePixmap) (pScreen, width, height, 32,
                                            CREATE_PIXMAP_USAGE_SCRATCH);
        if (!pPixmap) {
            free(argbbits);
            free(srcbits);
            free(mskbits);
            return BadAlloc;
        }
        pPicture = CreatePicture(0, &pPixmap.drawable, pFormat, 0, 0,
                                 client, &error);
        if (!pPicture) {
            free(argbbits);
            free(srcbits);
            free(mskbits);
            return error;
        }
        dixDestroyPixmap(pPixmap, 0);
        CompositePicture(PictOpSrc,
                         pSrc, 0, pPicture, 0, 0, 0, 0, 0, 0, width, height);
        (*pScreen.GetImage) (pPicture.pDrawable,
                              0, 0, width, height, ZPixmap,
                              0xffffffff, cast(void*) argbbits);
        FreePicture(pPicture, 0);
    }
    /*
     * Check whether the cursor can be directly supported by
     * the core cursor code
     */
    ncolor = 0;
    argb = argbbits;
    for (y = 0; ncolor <= 2 && y < height; y++) {
        for (x = 0; ncolor <= 2 && x < width; x++) {
            CARD32 p = *argb++;
            CARD32 a = (p >> 24);

            if (a == 0)         /* transparent */
                continue;
            if (a == 0xff) {    /* opaque */
                int n = void;

                for (n = 0; n < ncolor; n++)
                    if (p == twocolor[n])
                        break;
                if (n == ncolor)
                    twocolor[ncolor++] = p;
            }
            else
                ncolor = 3;
        }
    }

    /*
     * Convert argb image to two plane cursor
     */
    srcline = srcbits;
    mskline = mskbits;
    argb = argbbits;
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            CARD32 p = *argb++;

            if (ncolor <= 2) {
                CARD32 a = ((p >> 24));

                RenderSetBit(mskline, x, a != 0);
                RenderSetBit(srcline, x, a != 0 && p == twocolor[0]);
            }
            else {
                CARD32 a = ((p >> 24) * DITHER_SIZE + 127) / 255;
                CARD32 i = ((CvtR8G8B8toY15(p) >> 7) * DITHER_SIZE + 127) / 255;
                CARD32 d = orderedDither[y & (DITHER_DIM - 1)][x & (DITHER_DIM - 1)];
                /* Set mask from dithered alpha value */
                RenderSetBit(mskline, x, a > d);
                /* Set src from dithered intensity value */
                RenderSetBit(srcline, x, a > d && i <= d);
            }
        }
        srcline += stride;
        mskline += stride;
    }
    /*
     * Dither to white and black if the cursor has more than two colors
     */
    if (ncolor > 2) {
        twocolor[0] = 0xff000000;
        twocolor[1] = 0xffffffff;
    }
    else {
        free(argbbits);
        argbbits = null;
    }

enum string GetByte(string p,string s) = `(((` ~ p ~ `) >> (` ~ s ~ `)) & 0xff)`;
enum string GetColor(string p,string s) = `(` ~ GetByte!(p,s) ~ ` | (` ~ GetByte!(p,s) ~ ` << 8))`;

    cm.width = width;
    cm.height = height;
    cm.xhot = stuff.x;
    cm.yhot = stuff.y;
    rc = AllocARGBCursor(srcbits, mskbits, argbbits, &cm,
                         mixin(GetColor!(`twocolor[0]`, `16`)),
                         mixin(GetColor!(`twocolor[0]`, `8`)),
                         mixin(GetColor!(`twocolor[0]`, `0`)),
                         mixin(GetColor!(`twocolor[1]`, `16`)),
                         mixin(GetColor!(`twocolor[1]`, `8`)),
                         mixin(GetColor!(`twocolor[1]`, `0`)),
                         &pCursor, client, stuff.cid);
    if (rc != Success)
        goto bail;
    if (!AddResource(stuff.cid, X11_RESTYPE_CURSOR, cast(void*) pCursor)) {
        rc = BadAlloc;
        goto bail;
    }

    return Success;
 bail:
    free(srcbits);
    free(mskbits);
    return rc;
}

private int SingleRenderSetPictureTransform(ClientPtr client, xRenderSetPictureTransformReq* stuff)
{
    PicturePtr pPicture = void;

    VERIFY_PICTURE(pPicture, stuff.picture, client, DixSetAttrAccess);
    return SetPictureTransform(pPicture, cast(PictTransform*) &stuff.transform);
}

private int ProcRenderQueryFilters(ClientPtr client)
{
    REQUEST(xRenderQueryFiltersReq);
    REQUEST_SIZE_MATCH(xRenderQueryFiltersReq);

    if (client.swapped)
        swapl(&stuff.drawable);

    DrawablePtr pDrawable = void;
    int nbytesName = void;
    int nnames = void;
    ScreenPtr pScreen = void;
    PictureScreenPtr ps = void;
    int i = void, j = void, len = void, total_bytes = void, rc = void;
    INT16* aliases = void;
    char* names = void;

    rc = dixLookupDrawable(&pDrawable, stuff.drawable, client, 0,
                           DixGetAttrAccess);
    if (rc != Success)
        return rc;

    pScreen = pDrawable.pScreen;
    nbytesName = 0;
    nnames = 0;
    ps = GetPictureScreenIfSet(pScreen);
    if (ps) {
        for (i = 0; i < ps.nfilters; i++)
            nbytesName += 1 + strlen(ps.filters[i].name);
        for (i = 0; i < ps.nfilterAliases; i++)
            nbytesName += 1 + strlen(ps.filterAliases[i].alias_);
        nnames = ps.nfilters + ps.nfilterAliases;
    }
    len = ((nnames + 1) >> 1) + bytes_to_int32(nbytesName);
    total_bytes = (len << 2);

    x_rpcbuf_t rpcbuf = { swapped: client.swapped, err_clear: TRUE };
    aliases = cast(INT16*) x_rpcbuf_reserve(&rpcbuf, total_bytes);
    if (!aliases)
        return BadAlloc;

    names = cast(char*) (aliases + ((nnames + 1) & ~1));

    if (ps) {

        /* fill in alias values */
        for (i = 0; i < ps.nfilters; i++)
            aliases[i] = FilterAliasNone;
        for (i = 0; i < ps.nfilterAliases; i++) {
            for (j = 0; j < ps.nfilters; j++)
                if (ps.filterAliases[i].filter_id == ps.filters[j].id)
                    break;
            if (j == ps.nfilters) {
                for (j = 0; j < ps.nfilterAliases; j++)
                    if (ps.filterAliases[i].filter_id ==
                        ps.filterAliases[j].alias_id) {
                        break;
                    }
                if (j == ps.nfilterAliases)
                    j = FilterAliasNone;
                else
                    j = j + ps.nfilters;
            }
            aliases[i + ps.nfilters] = j;
        }

        /* fill in filter names */
        for (i = 0; i < ps.nfilters; i++) {
            j = strlen(ps.filters[i].name);
            *names++ = j;
            memcpy(names, ps.filters[i].name, j);
            names += j;
        }

        /* fill in filter alias names */
        for (i = 0; i < ps.nfilterAliases; i++) {
            j = strlen(ps.filterAliases[i].alias_);
            *names++ = j;
            memcpy(names, ps.filterAliases[i].alias_, j);
            names += j;
        }
    }

    xRenderQueryFiltersReply reply = {
        numAliases: nnames,
        numFilters: nnames
    };

    if (client.swapped) {
        for (i = 0; i < nnames; i++) {
            swaps(&aliases[i]);
        }
        swapl(&reply.numAliases);
        swapl(&reply.numFilters);
    }

    return X_SEND_REPLY_WITH_RPCBUF(client, reply, rpcbuf);
}

private int SingleRenderSetPictureFilter(ClientPtr client, xRenderSetPictureFilterReq* stuff)
{
    PicturePtr pPicture = void;
    int result = void;
    xFixed* params = void;
    int nparams = void;
    char* name = void;

    VERIFY_PICTURE(pPicture, stuff.picture, client, DixSetAttrAccess);
    name = cast(char*) (stuff + 1);
    params = cast(xFixed*) (name + pad_to_int32(stuff.nbytes));
    nparams = (cast(xFixed*) stuff + client.req_len) - params;
    if (nparams < 0)
	return BadLength;

    result = SetPictureFilter(pPicture, name, stuff.nbytes, params, nparams);
    return result;
}

private int ProcRenderCreateAnimCursor(ClientPtr client)
{
    REQUEST(xRenderCreateAnimCursorReq);
    REQUEST_AT_LEAST_SIZE(xRenderCreateAnimCursorReq);

    if (client.swapped) {
        swapl(&stuff.cid);
        SwapRestL(stuff);
    }

    CARD32* deltas = void;
    CursorPtr pCursor = void;
    xAnimCursorElt* elt = void;
    int i = void;
    int ret = void;

    LEGAL_NEW_RESOURCE(stuff.cid, client);
    if (client.req_len & 1)
        return BadLength;

    int ncursor = (client.req_len -
         (bytes_to_int32(xRenderCreateAnimCursorReq.sizeof))) >> 1;
    if (ncursor <= 0)
        return BadValue;

    CursorPtr* cursors = cast(CursorPtr*) calloc(ncursor, ((CursorPtr) + CARD32.sizeof).sizeof);
    if (!cursors)
        return BadAlloc;
    deltas = cast(CARD32*) (cursors + ncursor);
    elt = cast(xAnimCursorElt*) (stuff + 1);
    for (i = 0; i < ncursor; i++) {
        ret = dixLookupResourceByType(cast(void**) (cursors + i), elt.cursor,
                                      X11_RESTYPE_CURSOR, client, DixReadAccess);
        if (ret != Success) {
            free(cursors);
            return ret;
        }
        deltas[i] = elt.delay;
        elt++;
    }
    ret = AnimCursorCreate(cursors, deltas, ncursor, &pCursor, client,
                           stuff.cid);
    free(cursors);
    if (ret != Success)
        return ret;

    if (AddResource(stuff.cid, X11_RESTYPE_CURSOR, cast(void*) pCursor))
        return Success;
    return BadAlloc;
}

private int SingleRenderAddTraps(ClientPtr client, xRenderAddTrapsReq* stuff)
{
    int ntraps = void;
    PicturePtr pPicture = void;

    VERIFY_PICTURE(pPicture, stuff.picture, client, DixWriteAccess);
    if (!pPicture.pDrawable)
        return BadDrawable;
    ntraps = (client.req_len << 2) - xRenderAddTrapsReq.sizeof;
    if (ntraps % xTrap.sizeof)
        return BadLength;
    ntraps /= xTrap.sizeof;
    if (ntraps)
        AddTraps(pPicture,
                 stuff.xOff, stuff.yOff, ntraps, cast(xTrap*) &stuff[1]);
    return Success;
}

private int SingleRenderCreateSolidFill(ClientPtr client, xRenderCreateSolidFillReq* stuff)
{
    PicturePtr pPicture = void;
    int error = 0;

    LEGAL_NEW_RESOURCE(stuff.pid, client);

    pPicture = CreateSolidPicture(stuff.pid, &stuff.color, &error);
    if (!pPicture)
        return error;
    /* security creation/labeling check */
    error = XaceHookResourceAccess(client, stuff.pid, PictureType,
                     pPicture, X11_RESTYPE_NONE, null, DixCreateAccess);
    if (error != Success)
        return error;
    if (!AddResource(stuff.pid, PictureType, cast(void*) pPicture))
        return BadAlloc;
    return Success;
}

private int SingleRenderCreateLinearGradient(ClientPtr client, xRenderCreateLinearGradientReq* stuff)
{
    PicturePtr pPicture = void;
    int len = void;
    int error = 0;
    xFixed* stops = void;
    xRenderColor* colors = void;

    LEGAL_NEW_RESOURCE(stuff.pid, client);

    len = (client.req_len << 2) - xRenderCreateLinearGradientReq.sizeof;
    if (stuff.nStops > UINT32_MAX / (((xFixed) + xRenderColor.sizeof).sizeof))
        return BadLength;
    if (len != stuff.nStops * (((xFixed) + xRenderColor.sizeof).sizeof))
        return BadLength;

    stops = cast(xFixed*) (stuff + 1);
    colors = cast(xRenderColor*) (stops + stuff.nStops);

    pPicture = CreateLinearGradientPicture(stuff.pid, &stuff.p1, &stuff.p2,
                                           stuff.nStops, stops, colors,
                                           &error);
    if (!pPicture)
        return error;
    /* security creation/labeling check */
    error = XaceHookResourceAccess(client, stuff.pid, PictureType,
                     pPicture, X11_RESTYPE_NONE, null, DixCreateAccess);
    if (error != Success)
        return error;
    if (!AddResource(stuff.pid, PictureType, cast(void*) pPicture))
        return BadAlloc;
    return Success;
}

private int SingleRenderCreateRadialGradient(ClientPtr client, xRenderCreateRadialGradientReq* stuff)
{
    PicturePtr pPicture = void;
    int len = void;
    int error = 0;
    xFixed* stops = void;
    xRenderColor* colors = void;

    LEGAL_NEW_RESOURCE(stuff.pid, client);

    len = (client.req_len << 2) - xRenderCreateRadialGradientReq.sizeof;
    if (stuff.nStops > UINT32_MAX / (((xFixed) + xRenderColor.sizeof).sizeof))
        return BadLength;
    if (len != stuff.nStops * (((xFixed) + xRenderColor.sizeof).sizeof))
        return BadLength;

    stops = cast(xFixed*) (stuff + 1);
    colors = cast(xRenderColor*) (stops + stuff.nStops);

    pPicture =
        CreateRadialGradientPicture(stuff.pid, &stuff.inner, &stuff.outer,
                                    stuff.inner_radius, stuff.outer_radius,
                                    stuff.nStops, stops, colors, &error);
    if (!pPicture)
        return error;
    /* security creation/labeling check */
    error = XaceHookResourceAccess(client, stuff.pid, PictureType,
                     pPicture, X11_RESTYPE_NONE, null, DixCreateAccess);
    if (error != Success)
        return error;
    if (!AddResource(stuff.pid, PictureType, cast(void*) pPicture))
        return BadAlloc;
    return Success;
}

private int SingleRenderCreateConicalGradient(ClientPtr client, xRenderCreateConicalGradientReq* stuff)
{
    PicturePtr pPicture = void;
    int len = void;
    int error = 0;
    xFixed* stops = void;
    xRenderColor* colors = void;

    LEGAL_NEW_RESOURCE(stuff.pid, client);

    len = (client.req_len << 2) - xRenderCreateConicalGradientReq.sizeof;
    if (stuff.nStops > UINT32_MAX / (((xFixed) + xRenderColor.sizeof).sizeof))
        return BadLength;
    if (len != stuff.nStops * (((xFixed) + xRenderColor.sizeof).sizeof))
        return BadLength;

    stops = cast(xFixed*) (stuff + 1);
    colors = cast(xRenderColor*) (stops + stuff.nStops);

    pPicture =
        CreateConicalGradientPicture(stuff.pid, &stuff.center, stuff.angle,
                                     stuff.nStops, stops, colors, &error);
    if (!pPicture)
        return error;
    /* security creation/labeling check */
    error = XaceHookResourceAccess(client, stuff.pid, PictureType,
                     pPicture, X11_RESTYPE_NONE, null, DixCreateAccess);
    if (error != Success)
        return error;
    if (!AddResource(stuff.pid, PictureType, cast(void*) pPicture))
        return BadAlloc;
    return Success;
}

private int ProcRenderDispatch(ClientPtr client)
{
    REQUEST(xReq);

    switch (stuff.data) {
        case X_RenderQueryVersion:             return ProcRenderQueryVersion(client);
        case X_RenderQueryPictFormats:         return ProcRenderQueryPictFormats(client);
        /* 0.7 */
        case X_RenderQueryPictIndexValues:     return ProcRenderQueryPictIndexValues(client);
        case X_RenderQueryDithers:             return BadImplementation;
        case X_RenderCreatePicture:            return ProcRenderCreatePicture(client);
        case X_RenderChangePicture:            return ProcRenderChangePicture(client);
        case X_RenderSetPictureClipRectangles: return ProcRenderSetPictureClipRectangles(client);
        case X_RenderFreePicture:              return ProcRenderFreePicture(client);
        case X_RenderComposite:                return ProcRenderComposite(client);
        case X_RenderScale:                    return BadImplementation;
        case X_RenderTrapezoids:               return ProcRenderTrapezoids(client);
        case X_RenderTriangles:                return ProcRenderTriangles(client);
        case X_RenderTriStrip:                 return ProcRenderTriStrip(client);
        case X_RenderTriFan:                   return ProcRenderTriFan(client);
        case X_RenderColorTrapezoids:          return BadImplementation;
        case X_RenderColorTriangles:           return BadImplementation;
/*      case X_RenderTransform:                return BadImplementation;            --> doesn't actually exist */
        case X_RenderCreateGlyphSet:           return ProcRenderCreateGlyphSet(client);
        case X_RenderReferenceGlyphSet:        return ProcRenderReferenceGlyphSet(client);
        case X_RenderFreeGlyphSet:             return ProcRenderFreeGlyphSet(client);
        case X_RenderAddGlyphs:                return ProcRenderAddGlyphs(client);
        case X_RenderAddGlyphsFromPicture:     return BadImplementation;
        case X_RenderFreeGlyphs:               return ProcRenderFreeGlyphs(client);
        case X_RenderCompositeGlyphs8:         return ProcRenderCompositeGlyphs(client);
        case X_RenderCompositeGlyphs16:        return ProcRenderCompositeGlyphs(client);
        case X_RenderCompositeGlyphs32:        return ProcRenderCompositeGlyphs(client);
        case X_RenderFillRectangles:           return ProcRenderFillRectangles(client);
        /* 0.5 */
        case X_RenderCreateCursor:             return ProcRenderCreateCursor(client);
        /* 0.6 */
        case X_RenderSetPictureTransform:      return ProcRenderSetPictureTransform(client);
        case X_RenderQueryFilters:             return ProcRenderQueryFilters(client);
        case X_RenderSetPictureFilter:         return ProcRenderSetPictureFilter(client);
        /* 0.8 */
        case X_RenderCreateAnimCursor:         return ProcRenderCreateAnimCursor(client);
        /* 0.9 */
        case X_RenderAddTraps:                 return ProcRenderAddTraps(client);
        /* 0.10 */
        case X_RenderCreateSolidFill:          return ProcRenderCreateSolidFill(client);
        case X_RenderCreateLinearGradient:     return ProcRenderCreateLinearGradient(client);
        case X_RenderCreateRadialGradient:     return ProcRenderCreateRadialGradient(client);
        case X_RenderCreateConicalGradient:    return ProcRenderCreateConicalGradient(client);
    default: break;}

    return BadRequest;
}

private void swapStops(void* stuff, int num)
{
    int i = void;
    CARD32* stops = void;
    CARD16* colors = void;

    stops = cast(CARD32*) (stuff);
    for (i = 0; i < num; ++i) {
        swapl(stops);
        ++stops;
    }
    colors = cast(CARD16*) (stops);
    for (i = 0; i < 4 * num; ++i) {
        swaps(colors);
        ++colors;
    }
}

version (XINERAMA) {
enum string VERIFY_XIN_PICTURE(string pPicture, string pid, string client, string mode) = `{
    int rc = dixLookupResourceByType(cast(void**)&(` ~ pPicture ~ `), ` ~ pid ~ `,
                                     XRT_PICTURE, ` ~ client ~ `, ` ~ mode ~ `);
    if (rc != Success)
	return rc;
}`;

enum string VERIFY_XIN_ALPHA(string pPicture, string pid, string client, string mode) = `{
    if (` ~ pid ~ ` == None) 
	` ~ pPicture ~ ` = 0; 
    else { 
	` ~ VERIFY_XIN_PICTURE!(pPicture, pid, client, mode) ~ `; 
    } 
} 
`;
private int PanoramiXRenderCreatePicture(ClientPtr client, xRenderCreatePictureReq* stuff)
{
    PanoramiXRes* refDraw = void, newPict = void;
    int result = void;

    result = dixLookupResourceByClass(cast(void**) &refDraw, stuff.drawable,
                                      XRC_DRAWABLE, client, DixWriteAccess);
    if (result != Success)
        return (result == BadValue) ? BadDrawable : result;
    if (((newPict = cast(PanoramiXRes*) calloc(1, PanoramiXRes.sizeof)) == 0))
        return BadAlloc;
    newPict.type = XRT_PICTURE;
    panoramix_setup_ids(newPict, client, stuff.pid);

    if (refDraw.type == XRT_WINDOW &&
        stuff.drawable == dixGetMasterScreen().root.drawable.id) {
        newPict.u.pict.root = TRUE;
    }
    else
        newPict.u.pict.root = FALSE;

    XINERAMA_FOR_EACH_SCREEN_BACKWARD({
        stuff.pid = newPict.info[walkScreenIdx].id;
        stuff.drawable = refDraw.info[walkScreenIdx].id;
        result = SingleRenderCreatePicture(client, stuff);
        if (result != Success)
            break;
    });

    if (result == Success)
        AddResource(newPict.info[0].id, XRT_PICTURE, newPict);
    else
        free(newPict);

    return result;
}

private int PanoramiXRenderChangePicture(ClientPtr client, xRenderChangePictureReq* stuff, Picture pictID)
{
    PanoramiXRes* pict = void;
    int result = Success;

    mixin(VERIFY_XIN_PICTURE!(`pict`, `pictID`, `client`, `DixWriteAccess`));

    XINERAMA_FOR_EACH_SCREEN_BACKWARD({
        result = SingleRenderChangePicture(client, stuff, pict.info[walkScreenIdx].id);
        if (result != Success)
            break;
    });

    return result;
}

private int PanoramiXRenderSetPictureClipRectangles(ClientPtr client, xRenderSetPictureClipRectanglesReq* stuff, Picture pictID)
{
    int result = Success;
    PanoramiXRes* pict = void;

    mixin(VERIFY_XIN_PICTURE!(`pict`, `pictID`, `client`, `DixWriteAccess`));

    XINERAMA_FOR_EACH_SCREEN_BACKWARD({
        result = SingleRenderSetPictureClipRectangles(client, stuff, pict.info[walkScreenIdx].id);
        if (result != Success)
            break;
    });

    return result;
}

private int PanoramiXRenderSetPictureTransform(ClientPtr client, xRenderSetPictureTransformReq* stuff)
{
    int result = Success;
    PanoramiXRes* pict = void;

    mixin(VERIFY_XIN_PICTURE!(`pict`, `stuff.picture`, `client`, `DixWriteAccess`));

    XINERAMA_FOR_EACH_SCREEN_BACKWARD({
        stuff.picture = pict.info[walkScreenIdx].id;
        result = SingleRenderSetPictureTransform(client, stuff);
        if (result != Success)
            break;
    });

    return result;
}

private int PanoramiXRenderSetPictureFilter(ClientPtr client, xRenderSetPictureFilterReq* stuff)
{
    int result = Success;
    PanoramiXRes* pict = void;

    mixin(VERIFY_XIN_PICTURE!(`pict`, `stuff.picture`, `client`, `DixWriteAccess`));

    XINERAMA_FOR_EACH_SCREEN_BACKWARD({
        stuff.picture = pict.info[walkScreenIdx].id;
        result = SingleRenderSetPictureFilter(client, stuff);
        if (result != Success)
            break;
    });

    return result;
}

private int PanoramiXRenderFreePicture(ClientPtr client)
{
    PanoramiXRes* pict = void;
    int result = Success;

    REQUEST(xRenderFreePictureReq);

    client.errorValue = stuff.picture;

    mixin(VERIFY_XIN_PICTURE!(`pict`, `stuff.picture`, `client`, `DixDestroyAccess`));

    XINERAMA_FOR_EACH_SCREEN_BACKWARD({
        stuff.picture = pict.info[walkScreenIdx].id;
        result = SingleRenderFreePicture(client);
        if (result != Success)
            break;
    });

    /* Since ProcRenderFreePicture is using FreeResource, it will free
       our resource for us on the last pass through the loop above */

    return result;
}

private int PanoramiXRenderComposite(ClientPtr client, xRenderCompositeReq* orig_req)
{
    PanoramiXRes* src = void, msk = void, dst = void;
    int result = Success;
    xRenderCompositeReq orig = *orig_req;

    mixin(VERIFY_XIN_PICTURE!(`src`, `orig.src`, `client`, `DixReadAccess`));
    mixin(VERIFY_XIN_ALPHA!(`msk`, `orig.mask`, `client`, `DixReadAccess`));
    mixin(VERIFY_XIN_PICTURE!(`dst`, `orig.dst`, `client`, `DixWriteAccess`));

    xRenderCompositeReq sub_req = orig;

    XINERAMA_FOR_EACH_SCREEN_FORWARD({
        sub_req.src = src.info[walkScreenIdx].id;
        if (src.u.pict.root) {
            sub_req.xSrc = orig.xSrc - walkScreen.x;
            sub_req.ySrc = orig.ySrc - walkScreen.y;
        }
        sub_req.dst = dst.info[walkScreenIdx].id;
        if (dst.u.pict.root) {
            sub_req.xDst = orig.xDst - walkScreen.x;
            sub_req.yDst = orig.yDst - walkScreen.y;
        }
        if (msk) {
            sub_req.mask = msk.info[walkScreenIdx].id;
            if (msk.u.pict.root) {
                sub_req.xMask = orig.xMask - walkScreen.x;
                sub_req.yMask = orig.yMask - walkScreen.y;
            }
        }
        result = SingleRenderComposite(client, &sub_req);
        if (result != Success)
            break;
    });

    return result;
}

private int PanoramiXRenderCompositeGlyphs(ClientPtr client, xRenderCompositeGlyphsReq* stuff)
{
    PanoramiXRes* src = void, dst = void;
    int result = Success;

    xGlyphElt origElt = void; xGlyphElt* elt = void;
    INT16 xSrc = void, ySrc = void;

    mixin(VERIFY_XIN_PICTURE!(`src`, `stuff.src`, `client`, `DixReadAccess`));
    mixin(VERIFY_XIN_PICTURE!(`dst`, `stuff.dst`, `client`, `DixWriteAccess`));

    if (client.req_len << 2 >= (((xRenderCompositeGlyphsReq) +
                                 xGlyphElt.sizeof).sizeof)) {
        elt = cast(xGlyphElt*) (stuff + 1);
        origElt = *elt;
        xSrc = stuff.xSrc;
        ySrc = stuff.ySrc;

        XINERAMA_FOR_EACH_SCREEN_FORWARD({
            stuff.src = src.info[walkScreenIdx].id;
            if (src.u.pict.root) {
                stuff.xSrc = xSrc - walkScreen.x;
                stuff.ySrc = ySrc - walkScreen.y;
            }
            stuff.dst = dst.info[walkScreenIdx].id;
            if (dst.u.pict.root) {
                elt.deltax = origElt.deltax - walkScreen.x;
                elt.deltay = origElt.deltay - walkScreen.y;
            }
            result = SingleRenderCompositeGlyphs(client, stuff);
            if (result != Success)
                break;
        });
    }

    return result;
}

private int PanoramiXRenderFillRectangles(ClientPtr client, xRenderFillRectanglesReq* stuff)
{
    PanoramiXRes* dst = void;
    int result = Success;
    char* extra = void;
    int extra_len = void;

    mixin(VERIFY_XIN_PICTURE!(`dst`, `stuff.dst`, `client`, `DixWriteAccess`));
    extra_len = (client.req_len << 2) - xRenderFillRectanglesReq.sizeof;
    if (extra_len && (extra = cast(char*) calloc(1, extra_len))) {
        memcpy(extra, stuff + 1, extra_len);

        XINERAMA_FOR_EACH_SCREEN_FORWARD({
            if (walkScreenIdx) /* skip screen #0 */
                memcpy(stuff + 1, extra, extra_len);
            if (dst.u.pict.root) {
                int x_off = walkScreen.x;
                int y_off = walkScreen.y;

                if (x_off || y_off) {
                    xRectangle* rects = cast(xRectangle*) (stuff + 1);
                    int i = extra_len / xRectangle.sizeof;

                    while (i--) {
                        rects.x -= x_off;
                        rects.y -= y_off;
                        rects++;
                    }
                }
            }
            stuff.dst = dst.info[walkScreenIdx].id;
            result = SingleRenderFillRectangles(client, stuff);
            if (result != Success)
                break;
        });

        free(extra);
    }

    return result;
}

private int PanoramiXRenderTrapezoids(ClientPtr client, xRenderTrapezoidsReq* stuff)
{
    PanoramiXRes* src = void, dst = void;
    int result = Success;

    char* extra = void;
    int extra_len = void;

    mixin(VERIFY_XIN_PICTURE!(`src`, `stuff.src`, `client`, `DixReadAccess`));
    mixin(VERIFY_XIN_PICTURE!(`dst`, `stuff.dst`, `client`, `DixWriteAccess`));

    extra_len = (client.req_len << 2) - xRenderTrapezoidsReq.sizeof;

    if (extra_len && (extra = cast(char*) calloc(1, extra_len))) {
        memcpy(extra, stuff + 1, extra_len);

        XINERAMA_FOR_EACH_SCREEN_FORWARD({
            if (walkScreenIdx) /* skip screen #0 */
                memcpy(stuff + 1, extra, extra_len);
            if (dst.u.pict.root) {
                int x_off = walkScreen.x;
                int y_off = walkScreen.y;

                if (x_off || y_off) {
                    xTrapezoid* trap = cast(xTrapezoid*) (stuff + 1);
                    int i = extra_len / xTrapezoid.sizeof;

                    while (i--) {
                        trap.top -= y_off;
                        trap.bottom -= y_off;
                        trap.left.p1.x -= x_off;
                        trap.left.p1.y -= y_off;
                        trap.left.p2.x -= x_off;
                        trap.left.p2.y -= y_off;
                        trap.right.p1.x -= x_off;
                        trap.right.p1.y -= y_off;
                        trap.right.p2.x -= x_off;
                        trap.right.p2.y -= y_off;
                        trap++;
                    }
                }
            }

            stuff.src = src.info[walkScreenIdx].id;
            stuff.dst = dst.info[walkScreenIdx].id;
            result = SingleRenderTrapezoids(client, stuff);

            if (result != Success)
                break;
        });

        free(extra);
    }

    return result;
}

private int PanoramiXRenderTriangles(ClientPtr client, xRenderTrianglesReq* stuff)
{
    PanoramiXRes* src = void, dst = void;
    int result = Success;

    char* extra = void;
    int extra_len = void;

    mixin(VERIFY_XIN_PICTURE!(`src`, `stuff.src`, `client`, `DixReadAccess`));
    mixin(VERIFY_XIN_PICTURE!(`dst`, `stuff.dst`, `client`, `DixWriteAccess`));

    extra_len = (client.req_len << 2) - xRenderTrianglesReq.sizeof;

    if (extra_len && (extra = cast(char*) calloc(1, extra_len))) {
        memcpy(extra, stuff + 1, extra_len);

        XINERAMA_FOR_EACH_SCREEN_FORWARD({
            if (walkScreenIdx) /* skip screen #0 */
                memcpy(stuff + 1, extra, extra_len);
            if (dst.u.pict.root) {
                int x_off = walkScreen.x;
                int y_off = walkScreen.y;

                if (x_off || y_off) {
                    xTriangle* tri = cast(xTriangle*) (stuff + 1);
                    int i = extra_len / xTriangle.sizeof;

                    while (i--) {
                        tri.p1.x -= x_off;
                        tri.p1.y -= y_off;
                        tri.p2.x -= x_off;
                        tri.p2.y -= y_off;
                        tri.p3.x -= x_off;
                        tri.p3.y -= y_off;
                        tri++;
                    }
                }
            }

            stuff.src = src.info[walkScreenIdx].id;
            stuff.dst = dst.info[walkScreenIdx].id;
            result = SingleRenderTriangles(client, stuff);

            if (result != Success)
                break;
        });

        free(extra);
    }

    return result;
}

private int PanoramiXRenderTriStrip(ClientPtr client, xRenderTriStripReq* stuff)
{
    PanoramiXRes* src = void, dst = void;
    int result = Success;

    char* extra = void;
    int extra_len = void;

    mixin(VERIFY_XIN_PICTURE!(`src`, `stuff.src`, `client`, `DixReadAccess`));
    mixin(VERIFY_XIN_PICTURE!(`dst`, `stuff.dst`, `client`, `DixWriteAccess`));

    extra_len = (client.req_len << 2) - xRenderTriStripReq.sizeof;

    if (extra_len && (extra = cast(char*) calloc(1, extra_len))) {
        memcpy(extra, stuff + 1, extra_len);

        XINERAMA_FOR_EACH_SCREEN_FORWARD({
            if (walkScreenIdx) /* skip screen #0 */
                memcpy(stuff + 1, extra, extra_len);
            if (dst.u.pict.root) {
                int x_off = walkScreen.x;
                int y_off = walkScreen.y;

                if (x_off || y_off) {
                    xPointFixed* fixed = cast(xPointFixed*) (stuff + 1);
                    int i = extra_len / xPointFixed.sizeof;

                    while (i--) {
                        fixed.x -= x_off;
                        fixed.y -= y_off;
                        fixed++;
                    }
                }
            }

            stuff.src = src.info[walkScreenIdx].id;
            stuff.dst = dst.info[walkScreenIdx].id;
            result = SingleRenderTriStrip(client, stuff);

            if (result != Success)
                break;
        });

        free(extra);
    }

    return result;
}

private int PanoramiXRenderTriFan(ClientPtr client, xRenderTriFanReq* stuff)
{
    PanoramiXRes* src = void, dst = void;
    int result = Success;
    char* extra = void;
    int extra_len = void;

    mixin(VERIFY_XIN_PICTURE!(`src`, `stuff.src`, `client`, `DixReadAccess`));
    mixin(VERIFY_XIN_PICTURE!(`dst`, `stuff.dst`, `client`, `DixWriteAccess`));

    extra_len = (client.req_len << 2) - xRenderTriFanReq.sizeof;

    if (extra_len && (extra = cast(char*) calloc(1, extra_len))) {
        memcpy(extra, stuff + 1, extra_len);

        XINERAMA_FOR_EACH_SCREEN_FORWARD({
            if (walkScreenIdx) /* skip screen #0 */
                memcpy(stuff + 1, extra, extra_len);
            if (dst.u.pict.root) {
                int x_off = walkScreen.x;
                int y_off = walkScreen.y;

                if (x_off || y_off) {
                    xPointFixed* fixed = cast(xPointFixed*) (stuff + 1);
                    int i = extra_len / xPointFixed.sizeof;

                    while (i--) {
                        fixed.x -= x_off;
                        fixed.y -= y_off;
                        fixed++;
                    }
                }
            }

            stuff.src = src.info[walkScreenIdx].id;
            stuff.dst = dst.info[walkScreenIdx].id;
            result = SingleRenderTriFan(client, stuff);

            if (result != Success)
                break;
        });

        free(extra);
    }

    return result;
}

private int PanoramiXRenderAddTraps(ClientPtr client, xRenderAddTrapsReq* stuff)
{
    PanoramiXRes* picture = void;
    int result = Success;
    char* extra = void;
    int extra_len = void;
    INT16 x_off = void, y_off = void;

    mixin(VERIFY_XIN_PICTURE!(`picture`, `stuff.picture`, `client`, `DixWriteAccess`));
    extra_len = (client.req_len << 2) - xRenderAddTrapsReq.sizeof;
    if (extra_len && (extra = cast(char*) calloc(1, extra_len))) {
        memcpy(extra, stuff + 1, extra_len);
        x_off = stuff.xOff;
        y_off = stuff.yOff;

        XINERAMA_FOR_EACH_SCREEN_FORWARD({
            if (walkScreenIdx) /* skip screen #0 */
                memcpy(stuff + 1, extra, extra_len);
            stuff.picture = picture.info[walkScreenIdx].id;

            if (picture.u.pict.root) {
                stuff.xOff = x_off + walkScreen.x;
                stuff.yOff = y_off + walkScreen.y;
            }
            result = SingleRenderAddTraps(client, stuff);
            if (result != Success)
                break;
        });

        free(extra);
    }

    return result;
}

private int PanoramiXRenderCreateSolidFill(ClientPtr client, xRenderCreateSolidFillReq* stuff)
{
    PanoramiXRes* newPict = void;
    int result = Success;

    if (((newPict = cast(PanoramiXRes*) calloc(1, PanoramiXRes.sizeof)) == 0))
        return BadAlloc;

    newPict.type = XRT_PICTURE;
    panoramix_setup_ids(newPict, client, stuff.pid);
    newPict.u.pict.root = FALSE;

    XINERAMA_FOR_EACH_SCREEN_BACKWARD({
        stuff.pid = newPict.info[walkScreenIdx].id;
        result = SingleRenderCreateSolidFill(client, stuff);
        if (result != Success)
            break;
    });

    if (result == Success)
        AddResource(newPict.info[0].id, XRT_PICTURE, newPict);
    else
        free(newPict);

    return result;
}

private int PanoramiXRenderCreateLinearGradient(ClientPtr client, xRenderCreateLinearGradientReq* stuff)
{
    PanoramiXRes* newPict = void;
    int result = Success;

    if (((newPict = cast(PanoramiXRes*) calloc(1, PanoramiXRes.sizeof)) == 0))
        return BadAlloc;

    newPict.type = XRT_PICTURE;
    panoramix_setup_ids(newPict, client, stuff.pid);
    newPict.u.pict.root = FALSE;

    XINERAMA_FOR_EACH_SCREEN_BACKWARD({
        stuff.pid = newPict.info[walkScreenIdx].id;
        result = SingleRenderCreateLinearGradient(client, stuff);
        if (result != Success)
            break;
    });

    if (result == Success)
        AddResource(newPict.info[0].id, XRT_PICTURE, newPict);
    else
        free(newPict);

    return result;
}

private int PanoramiXRenderCreateRadialGradient(ClientPtr client, xRenderCreateRadialGradientReq* stuff)
{
    PanoramiXRes* newPict = void;
    int result = Success;

    if (((newPict = cast(PanoramiXRes*) calloc(1, PanoramiXRes.sizeof)) == 0))
        return BadAlloc;

    newPict.type = XRT_PICTURE;
    panoramix_setup_ids(newPict, client, stuff.pid);
    newPict.u.pict.root = FALSE;

    XINERAMA_FOR_EACH_SCREEN_BACKWARD({
        stuff.pid = newPict.info[walkScreenIdx].id;
        result = SingleRenderCreateRadialGradient(client, stuff);
        if (result != Success)
            break;
    });

    if (result == Success)
        AddResource(newPict.info[0].id, XRT_PICTURE, newPict);
    else
        free(newPict);

    return result;
}

private int PanoramiXRenderCreateConicalGradient(ClientPtr client, xRenderCreateConicalGradientReq* stuff)
{
    PanoramiXRes* newPict = void;
    int result = Success;

    if (((newPict = cast(PanoramiXRes*) calloc(1, PanoramiXRes.sizeof)) == 0))
        return BadAlloc;

    newPict.type = XRT_PICTURE;
    panoramix_setup_ids(newPict, client, stuff.pid);
    newPict.u.pict.root = FALSE;

    XINERAMA_FOR_EACH_SCREEN_BACKWARD({
        stuff.pid = newPict.info[walkScreenIdx].id;
        result = SingleRenderCreateConicalGradient(client, stuff);
        if (result != Success)
            break;
    });

    if (result == Success)
        AddResource(newPict.info[0].id, XRT_PICTURE, newPict);
    else
        free(newPict);

    return result;
}

void PanoramiXRenderInit()
{
    XRT_PICTURE = CreateNewResourceType(XineramaDeleteResource,
                                        "XineramaPicture");
    if (RenderErrBase)
        SetResourceTypeErrorValue(XRT_PICTURE, RenderErrBase + BadPicture);

    usePanoramiX = TRUE;
}

void PanoramiXRenderReset()
{
    RenderErrBase = 0;
    usePanoramiX = FALSE;
}

} /* XINERAMA */

private int ProcRenderCreatePicture(ClientPtr client)
{
    REQUEST(xRenderCreatePictureReq);
    REQUEST_AT_LEAST_SIZE(xRenderCreatePictureReq);

    if (client.swapped) {
        swapl(&stuff.pid);
        swapl(&stuff.drawable);
        swapl(&stuff.format);
        swapl(&stuff.mask);
        SwapRestL(stuff);
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderCreatePicture(client, stuff)
                         : SingleRenderCreatePicture(client, stuff));
} else {
    return SingleRenderCreatePicture(client, stuff);
}
}

private int ProcRenderChangePicture(ClientPtr client)
{
    REQUEST(xRenderChangePictureReq);
    REQUEST_AT_LEAST_SIZE(xRenderChangePictureReq);

    if (client.swapped) {
        swapl(&stuff.picture);
        swapl(&stuff.mask);
        SwapRestL(stuff);
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderChangePicture(client, stuff, stuff.picture)
                         : SingleRenderChangePicture(client, stuff, stuff.picture));
} else {
    return SingleRenderChangePicture(client, stuff, stuff.picture);
}
}

private int ProcRenderSetPictureClipRectangles(ClientPtr client)
{
    REQUEST(xRenderSetPictureClipRectanglesReq);
    REQUEST_AT_LEAST_SIZE(xRenderSetPictureClipRectanglesReq);

    if (client.swapped) {
        swapl(&stuff.picture);
        swaps(&stuff.xOrigin);
        swaps(&stuff.yOrigin);
        SwapRestS(stuff);
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderSetPictureClipRectangles(client, stuff, stuff.picture)
                         : SingleRenderSetPictureClipRectangles(client, stuff, stuff.picture));
} else {
    return SingleRenderSetPictureClipRectangles(client, stuff, stuff.picture);
}
}

private int ProcRenderFreePicture(ClientPtr client)
{
    REQUEST(xRenderFreePictureReq);
    REQUEST_SIZE_MATCH(xRenderFreePictureReq);

    if (client.swapped)
        swapl(&stuff.picture);

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderFreePicture(client)
                         : SingleRenderFreePicture(client));
} else {
    return SingleRenderFreePicture(client);
}
}

private int ProcRenderComposite(ClientPtr client)
{
    REQUEST(xRenderCompositeReq);
    REQUEST_SIZE_MATCH(xRenderCompositeReq);

    if (client.swapped) {
        swapl(&stuff.src);
        swapl(&stuff.mask);
        swapl(&stuff.dst);
        swaps(&stuff.xSrc);
        swaps(&stuff.ySrc);
        swaps(&stuff.xMask);
        swaps(&stuff.yMask);
        swaps(&stuff.xDst);
        swaps(&stuff.yDst);
        swaps(&stuff.width);
        swaps(&stuff.height);
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderComposite(client, stuff)
                         : SingleRenderComposite(client, stuff));
} else {
    return SingleRenderComposite(client, stuff);
}
}

private int ProcRenderTrapezoids(ClientPtr client)
{
    REQUEST(xRenderTrapezoidsReq);
    REQUEST_AT_LEAST_SIZE(xRenderTrapezoidsReq);

    if (client.swapped) {
        swapl(&stuff.src);
        swapl(&stuff.dst);
        swapl(&stuff.maskFormat);
        swaps(&stuff.xSrc);
        swaps(&stuff.ySrc);
        SwapRestL(stuff);
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderTrapezoids(client, stuff)
                         : SingleRenderTrapezoids(client, stuff));
} else {
    return SingleRenderTrapezoids(client, stuff);
}
}

private int ProcRenderTriangles(ClientPtr client)
{
    REQUEST(xRenderTrianglesReq);
    REQUEST_AT_LEAST_SIZE(xRenderTrianglesReq);

    if (client.swapped) {
        swapl(&stuff.src);
        swapl(&stuff.dst);
        swapl(&stuff.maskFormat);
        swaps(&stuff.xSrc);
        swaps(&stuff.ySrc);
        SwapRestL(stuff);
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderTriangles(client, stuff)
                         : SingleRenderTriangles(client, stuff));
} else {
    return SingleRenderTriangles(client, stuff);
}
}

private int ProcRenderTriStrip(ClientPtr client)
{
    REQUEST(xRenderTriStripReq);
    REQUEST_AT_LEAST_SIZE(xRenderTriStripReq);

    if (client.swapped) {
        swapl(&stuff.src);
        swapl(&stuff.dst);
        swapl(&stuff.maskFormat);
        swaps(&stuff.xSrc);
        swaps(&stuff.ySrc);
        SwapRestL(stuff);
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderTriStrip(client, stuff)
                         : SingleRenderTriStrip(client, stuff));
} else {
    return SingleRenderTriStrip(client, stuff);
}
}

private int ProcRenderTriFan(ClientPtr client)
{
    REQUEST(xRenderTriFanReq);
    REQUEST_AT_LEAST_SIZE(xRenderTriFanReq);

    if (client.swapped) {
        swapl(&stuff.src);
        swapl(&stuff.dst);
        swapl(&stuff.maskFormat);
        swaps(&stuff.xSrc);
        swaps(&stuff.ySrc);
        SwapRestL(stuff);
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderTriFan(client, stuff)
                         : SingleRenderTriFan(client, stuff));
} else {
    return SingleRenderTriFan(client, stuff);
}
}

private int ProcRenderCompositeGlyphs(ClientPtr client)
{
    REQUEST(xRenderCompositeGlyphsReq);
    REQUEST_AT_LEAST_SIZE(xRenderCompositeGlyphsReq);

    if (client.swapped) {
        int size = 0;

        switch (stuff.renderReqType) {
            default:
                size = 1;
                break;
            case X_RenderCompositeGlyphs16:
                size = 2;
            break;
            case X_RenderCompositeGlyphs32:
                size = 4;
            break;
        }

        swapl(&stuff.src);
        swapl(&stuff.dst);
        swapl(&stuff.maskFormat);
        swapl(&stuff.glyphset);
        swaps(&stuff.xSrc);
        swaps(&stuff.ySrc);

        CARD8* buffer = cast(CARD8*) (stuff + 1);
        CARD8* end = cast(CARD8*) stuff + (client.req_len << 2);
        while (buffer + xGlyphElt.sizeof < end) {
            xGlyphElt* elt = cast(xGlyphElt*) buffer;
            buffer += xGlyphElt.sizeof;

            swaps(&elt.deltax);
            swaps(&elt.deltay);

            int i = elt.len;
            if (i == 0xff) {
                if (buffer + 4 > end) {
                    return BadLength;
                }
                swapl(cast(int*) buffer);
                buffer += 4;
            }
            else {
                int space = size * i;
                switch (size) {
                    case 1:
                        buffer += i;
                    break;
                    case 2:
                        if (buffer + i * 2 > end) {
                            return BadLength;
                        }
                        while (i--) {
                            swaps(cast(short*) buffer);
                            buffer += 2;
                        }
                    break;
                    case 4:
                        if (buffer + i * 4 > end) {
                            return BadLength;
                        }
                        while (i--) {
                            swapl(cast(int*) buffer);
                            buffer += 4;
                        }
                    break;
                default: break;}
                if (space & 3)
                    buffer += 4 - (space & 3);
            }
        }
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderCompositeGlyphs(client, stuff)
                         : SingleRenderCompositeGlyphs(client, stuff));
} else {
    return SingleRenderCompositeGlyphs(client, stuff);
}
}

private int ProcRenderFillRectangles(ClientPtr client)
{
    REQUEST(xRenderFillRectanglesReq);
    REQUEST_AT_LEAST_SIZE(xRenderFillRectanglesReq);

    if (client.swapped) {
        swapl(&stuff.dst);
        swaps(&stuff.color.red);
        swaps(&stuff.color.green);
        swaps(&stuff.color.blue);
        swaps(&stuff.color.alpha);
        SwapRestS(stuff);
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderFillRectangles(client, stuff)
                         : SingleRenderFillRectangles(client, stuff));
} else {
    return SingleRenderFillRectangles(client, stuff);
}
}

private int ProcRenderSetPictureTransform(ClientPtr client)
{
    REQUEST(xRenderSetPictureTransformReq);
    REQUEST_SIZE_MATCH(xRenderSetPictureTransformReq);

    if (client.swapped) {
        swapl(&stuff.picture);
        swapl(&stuff.transform.matrix11);
        swapl(&stuff.transform.matrix12);
        swapl(&stuff.transform.matrix13);
        swapl(&stuff.transform.matrix21);
        swapl(&stuff.transform.matrix22);
        swapl(&stuff.transform.matrix23);
        swapl(&stuff.transform.matrix31);
        swapl(&stuff.transform.matrix32);
        swapl(&stuff.transform.matrix33);
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderSetPictureTransform(client, stuff)
                         : SingleRenderSetPictureTransform(client, stuff));
} else {
    return SingleRenderSetPictureTransform(client, stuff);
}
}

private int ProcRenderSetPictureFilter(ClientPtr client)
{
    REQUEST(xRenderSetPictureFilterReq);
    REQUEST_AT_LEAST_SIZE(xRenderSetPictureFilterReq);

    if (client.swapped) {
        swapl(&stuff.picture);
        swaps(&stuff.nbytes);
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderSetPictureFilter(client, stuff)
                         : SingleRenderSetPictureFilter(client, stuff));
} else {
    return SingleRenderSetPictureFilter(client, stuff);
}
}

private int ProcRenderAddTraps(ClientPtr client)
{
    REQUEST(xRenderAddTrapsReq);
    REQUEST_AT_LEAST_SIZE(xRenderAddTrapsReq);

    if (client.swapped) {
        swapl(&stuff.picture);
        swaps(&stuff.xOff);
        swaps(&stuff.yOff);
        SwapRestL(stuff);
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderAddTraps(client, stuff)
                         : SingleRenderAddTraps(client, stuff));
} else {
    return SingleRenderAddTraps(client, stuff);
}
}

private int ProcRenderCreateSolidFill(ClientPtr client)
{
    REQUEST(xRenderCreateSolidFillReq);
    REQUEST_AT_LEAST_SIZE(xRenderCreateSolidFillReq);

    if (client.swapped) {
        swapl(&stuff.pid);
        swaps(&stuff.color.alpha);
        swaps(&stuff.color.red);
        swaps(&stuff.color.green);
        swaps(&stuff.color.blue);
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderCreateSolidFill(client, stuff)
                         : SingleRenderCreateSolidFill(client, stuff));
} else {
    return SingleRenderCreateSolidFill(client, stuff);
}
}

private int ProcRenderCreateLinearGradient(ClientPtr client)
{
    REQUEST(xRenderCreateLinearGradientReq);
    REQUEST_AT_LEAST_SIZE(xRenderCreateLinearGradientReq);

    if (client.swapped) {
        swapl(&stuff.pid);
        swapl(&stuff.p1.x);
        swapl(&stuff.p1.y);
        swapl(&stuff.p2.x);
        swapl(&stuff.p2.y);
        swapl(&stuff.nStops);

        int len = (client.req_len << 2) - xRenderCreateLinearGradientReq.sizeof;
        if (stuff.nStops > UINT32_MAX / (((xFixed) + xRenderColor.sizeof).sizeof))
            return BadLength;
        if (len != stuff.nStops * (((xFixed) + xRenderColor.sizeof).sizeof))
            return BadLength;

        swapStops(stuff + 1, stuff.nStops);
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderCreateLinearGradient(client, stuff)
                         : SingleRenderCreateLinearGradient(client, stuff));
} else {
    return SingleRenderCreateLinearGradient(client, stuff);
}
}

private int ProcRenderCreateRadialGradient(ClientPtr client)
{
    REQUEST(xRenderCreateRadialGradientReq);
    REQUEST_AT_LEAST_SIZE(xRenderCreateRadialGradientReq);

    if (client.swapped) {
        swapl(&stuff.pid);
        swapl(&stuff.inner.x);
        swapl(&stuff.inner.y);
        swapl(&stuff.outer.x);
        swapl(&stuff.outer.y);
        swapl(&stuff.inner_radius);
        swapl(&stuff.outer_radius);
        swapl(&stuff.nStops);

        int len = (client.req_len << 2) - xRenderCreateRadialGradientReq.sizeof;
        if (stuff.nStops > UINT32_MAX / (((xFixed) + xRenderColor.sizeof).sizeof))
            return BadLength;
        if (len != stuff.nStops * (((xFixed) + xRenderColor.sizeof).sizeof))
            return BadLength;

        swapStops(stuff + 1, stuff.nStops);
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderCreateRadialGradient(client, stuff)
                         : SingleRenderCreateRadialGradient(client, stuff));
} else {
    return SingleRenderCreateRadialGradient(client, stuff);
}
}

private int ProcRenderCreateConicalGradient(ClientPtr client)
{
    REQUEST(xRenderCreateConicalGradientReq);
    REQUEST_AT_LEAST_SIZE(xRenderCreateConicalGradientReq);

    if (client.swapped) {
        swapl(&stuff.pid);
        swapl(&stuff.center.x);
        swapl(&stuff.center.y);
        swapl(&stuff.angle);
        swapl(&stuff.nStops);

        int len = (client.req_len << 2) - xRenderCreateConicalGradientReq.sizeof;
        if (stuff.nStops > UINT32_MAX / (((xFixed) + xRenderColor.sizeof).sizeof))
            return BadLength;
        if (len != stuff.nStops * (((xFixed) + xRenderColor.sizeof).sizeof))
            return BadLength;

        swapStops(stuff + 1, stuff.nStops);
    }

version (XINERAMA) {
    return (usePanoramiX ? PanoramiXRenderCreateConicalGradient(client, stuff)
                         : SingleRenderCreateConicalGradient(client, stuff));
} else {
    return SingleRenderCreateConicalGradient(client, stuff);
}
}
