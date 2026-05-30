module dpmsproc;
@nogc nothrow:
extern(C): __gshared:
/* Prototypes for functions that the DDX must provide */

 
public import build.dix_config;

public import dixstruct;

extern int DPMSSet(ClientPtr client, int level);
extern Bool DPMSSupported();

extern CARD32 DPMSStandbyTime;
extern CARD32 DPMSSuspendTime;
extern CARD32 DPMSOffTime;
extern CARD16 DPMSPowerLevel;
extern Bool DPMSEnabled;
extern Bool DPMSDisabledSwitch;


