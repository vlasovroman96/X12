module picturestr_priv.h;
@nogc nothrow:
extern(C): __gshared:
/* SPDX-License-Identifier: MIT OR X11
 *
 * Copyright © 2024 Enrico Weigelt, metux IT consult <info@metux.net>
 * Copyright © 2000 SuSE, Inc.
 */
 
public import include.picturestr;
public import include.scrnintstr;
public import glyphstr;
public import include.resource;
public import include.privates;

enum PICT_GRADIENT_STOPTABLE_SIZE = 1024;

extern RESTYPE PictureType;
extern RESTYPE PictFormatType;
extern RESTYPE GlyphSetType;

enum string VERIFY_PICTURE(string pPicture, string pid, string client, string mode) = `{
    int tmprc = dixLookupResourceByType(cast(void*)&(` ~ pPicture ~ `), ` ~ pid ~ `,
	                                PictureType, ` ~ client ~ `, ` ~ mode ~ `);
    if (tmprc != Success)
	return tmprc;
}`;

enum string VERIFY_ALPHA(string pPicture, string pid, string client, string mode) = `{
    if (` ~ pid ~ ` == None) 
	` ~ pPicture ~ ` = 0; 
    else { 
	` ~ VERIFY_PICTURE!(pPicture, pid, client, mode) ~ `; 
    } 
} 
`;
Bool AnimCurInit(ScreenPtr pScreen);

int AnimCursorCreate(CursorPtr* cursors, CARD32* deltas, int ncursor, CursorPtr* ppCursor, ClientPtr client, XID cid);

version (XINERAMA) {
void PanoramiXRenderInit();
void PanoramiXRenderReset();
} /* XINERAMA */

 /* _XSERVER_PICTURESTR_PRIV_H_ */
