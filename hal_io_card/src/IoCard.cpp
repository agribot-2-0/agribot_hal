#include <hal_iocard/IoCard.h>

#define  deviceDescription  L"PCIe-1730,BID#8"

IoCard::IoCard(eCardMode eMode)
{
    this->_Ret = Success;
    this->_eSelMode = NOT_SELECTED;

    if ((eMode&INPUT) == INPUT)
    {
        this->_pInstantDiCtrl = InstantDiCtrl_Create();
        this->_eSelMode = this->_eSelMode | INPUT;
    }
    if ((eMode&OUTPUT) == OUTPUT)
    {
        this->_pInstantDoCtrl = InstantDoCtrl_Create();
        this->_eSelMode = this->_eSelMode | OUTPUT;
    }
}

IoCard::~IoCard()
{
    if ((this->_eSelMode&INPUT) == INPUT)
    {
        InstantDiCtrl_Dispose(_pInstantDiCtrl);
    }
    if ((this->_eSelMode&OUTPUT) == OUTPUT)
    {
        InstantDoCtrl_Dispose(_pInstantDoCtrl);
    }
}

void IoCard::vWritePort(int32 i32PortNum, uint8_t u8PinMask)
{
    if (this->_eSelMode == OUTPUT)
    {
        _Ret = Success;
        wchar_t enumString[256];
        byte dataBuffer[64] = {0};  // the first element is used for start port
        do
        {
            DeviceInformation devInfo;
            devInfo.DeviceNumber = -1;
            devInfo.DeviceMode = ModeWrite;
            devInfo.ModuleIndex = 0;
            wcscpy(devInfo.Description, deviceDescription);
            _Ret = InstantDoCtrl_setSelectedDevice(_pInstantDoCtrl, &devInfo);
            CHK_RESULT(_Ret);
            _Ret = InstantDoCtrl_LoadProfile(_pInstantDoCtrl, _pProfilePath);
            CHK_RESULT(_Ret);
            dataBuffer[i32PortNum] = u8PinMask;
            _Ret = InstantDoCtrl_WriteAny(_pInstantDoCtrl, i32PortNum,
                                         1, dataBuffer);
            CHK_RESULT(_Ret);
        }while (FALSE);

        if (BioFailed(_Ret))
        {
            AdxEnumToString(L"ErrorCode", static_cast<int32>(_Ret),
                                                             256,
                                                             enumString);
            printf("Some error occurred. The last error code is 0x%X. [%ls]\n",
                    _Ret, enumString);
        }
    }
    else
    {
        // Wrong mode
    }
}

uint8_t IoCard::u8ReadPort(int32 readPort)
{
    if (this->_eSelMode == INPUT)
    {
        int i;
        byte dataBuffer[64] = {0};
        do
        {
            DeviceInformation devInfo;
            devInfo.DeviceNumber = -1;
            devInfo.DeviceMode = ModeWrite;
            devInfo.ModuleIndex = 0;
            wcscpy(devInfo.Description, deviceDescription);
            _Ret = InstantDiCtrl_setSelectedDevice(_pInstantDiCtrl, &devInfo);
            CHK_RESULT(_Ret);
            _Ret = InstantDiCtrl_LoadProfile(_pInstantDiCtrl, _pProfilePath);
            CHK_RESULT(_Ret);
            _Ret = InstantDiCtrl_ReadAny(_pInstantDiCtrl, readPort,
                                         1, dataBuffer);
            CHK_RESULT(_Ret);
        } while (FALSE);
        return dataBuffer[readPort];
    }
    else
    {
        // Wrong mode selected
    }
}
