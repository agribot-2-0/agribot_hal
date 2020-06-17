#pragma once
#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <wchar.h>
#include <hal_iocard/compatibility.h>
#include <hal_iocard/bdaqctrl.h>

#define PORT0 0x00
#define PORT1 0x01

typedef unsigned char byte;
enum eCardMode {NOT_SELECTED, INPUT, OUTPUT};
inline eCardMode operator|(eCardMode a, eCardMode b)
{
    return static_cast<eCardMode>(static_cast<uint8_t>(a) | static_cast<uint8_t>(b));
}

class IoCard
{
private:
    InstantDoCtrl *_pInstantDoCtrl;
    InstantDiCtrl *_pInstantDiCtrl;
    ErrorCode _Ret;
    const wchar_t* _pProfilePath = L"../DemoDevice.xml";
    eCardMode _eSelMode;
public:
    IoCard(eCardMode Mode);
    ~IoCard();
    void vWritePort(int32 i32PortNum, uint8_t u8PinMask);
    uint8_t u8ReadPort(int32 readPort);
};