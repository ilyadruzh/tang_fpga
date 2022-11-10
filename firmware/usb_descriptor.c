/**
 * @file usbd_ftdi.c
 * @brief 
 * 
 * Copyright (c) 2021 Sipeed team
 * 
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.  The
 * ASF licenses this file to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the
 * License.  You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
 * License for the specific language governing permissions and limitations
 * under the License.
 * 
 */
 
#include "hal_usb.h"
#include "usbd_core.h"
#include "usbd_ftdi.h"
#include "bl702_usb.h"

const uint16_t ftdi_eeprom_info[] = 
{
	0x0800, 0x0403, 0x6010, 0x0700, 0x2D80, 0x0000, 0x0000, 0x0A9A,
	0x1CA4, 0x0000, 0x0000, 0x0000, 0x0046, 0x030A, 0x0046, 0x0054,
	0x0044, 0x0049, 0x031C, 0x0044, 0x0075, 0x0061, 0x006C, 0x0020,
	0x0052, 0x0053, 0x0032, 0x0033, 0x0032, 0x002D, 0x0048, 0x0053,
	0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
	0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x368D
};

// const uint16_t ftdi_eeprom_info[] = 
// {
//     0x0108, 0x0403, 0x6010, 0x0700, 0x3280, 0x0008, 0x0000, 0x0A9A, 
//     0x2CA4, 0x16D0, 0x0000, 0x0000, 0x0046, 0x030A, 0x0046, 0x0054 ,   
//     0x0044, 0x0049, 0x032C, 0x0042, 0x006F, 0x0075, 0x0066, 0x0066 ,   
//     0x0061, 0x006C, 0x006F, 0x0020, 0x004C, 0x0061, 0x0062, 0x0020 ,  
//     0x0044, 0x0065, 0x0062, 0x0075, 0x0067, 0x0067, 0x0065, 0x0072,
//     0x0316, 0x0042, 0x0046, 0x004C, 0x0042, 0x0031, 0x0032, 0x0033 ,  
//     0x0034, 0x0035, 0x0036, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000 ,
//     0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x53FC ,       
// };
uint8_t cdc_descriptor[] =
{
    ///////////////////////////////////////
    /// device descriptor
    ///////////////////////////////////////
    0x12,                       /* bLength */
    USB_DESCRIPTOR_TYPE_DEVICE, /* bDescriptorType */
    0x00, 0x02,                 /* bcdUSB */
    0x00,                       /* bDeviceClass */
    0x00,                       /* bDeviceSubClass */
    0x00,                       /* bDeviceProtocol */
    0x40,                       /* bMaxPacketSize */
    0x03, 0x04,                 /* idVendor */
    0x10, 0x60,                 /* idProduct */
    0x00, 0x05,                 /* bcdDevice */
    0x01,                       /* iManufacturer */
    0x02,                       /* iProduct */
    0x03,                       /* iSerial */
    0x01,                       /* bNumConfigurations */

    ///////////////////////////////////////
    /// config descriptor
    ///////////////////////////////////////
    0x09,                              /* bLength */
    USB_DESCRIPTOR_TYPE_CONFIGURATION, /* bDescriptorType */
    0x37, 0x00,                        /* wTotalLength */
    0x02,                              /* bNumInterfaces */
    0x01,                              /* bConfigurationValue */
    0x00,                              /* iConfiguration */
    0x80,                              /* bmAttributes */
    0x2d,                              /* bMaxPower */

    ///////////////////////////////////////
    /// interface descriptor
    ///////////////////////////////////////
    0x09,                          /* bLength */
    USB_DESCRIPTOR_TYPE_INTERFACE, /* bDescriptorType */
    0x00,                          /* bInterfaceNumber */
    0x00,                          /* bAlternateSetting */
    0x02,                          /* bNumEndpoints */
    0xff,                          /* bInterfaceClass */
    0xff,                          /* bInterfaceSubClass */
    0xff,                          /* bInterfaceProtocol */
    0x02,                          /* iInterface */

    ///////////////////////////////////////
    /// endpoint descriptor
    ///////////////////////////////////////
    0x07,                         /* bLength */
    USB_DESCRIPTOR_TYPE_ENDPOINT, /* bDescriptorType */
    0x81,                         /* bEndpointAddress */
    0x02,                         /* bmAttributes */
    0x40, 0x00,                   /* wMaxPacketSize */
    0x01,                         /* bInterval */

    ///////////////////////////////////////
    /// endpoint descriptor
    ///////////////////////////////////////
    0x07,                         /* bLength */
    USB_DESCRIPTOR_TYPE_ENDPOINT, /* bDescriptorType */
    0x02,                         /* bEndpointAddress */
    0x02,                         /* bmAttributes */
    0x40, 0x00,                   /* wMaxPacketSize */
    0x01,                         /* bInterval */

    ///////////////////////////////////////
    /// interface descriptor
    ///////////////////////////////////////
    0x09,                          /* bLength */
    USB_DESCRIPTOR_TYPE_INTERFACE, /* bDescriptorType */
    0x01,                          /* bInterfaceNumber */
    0x00,                          /* bAlternateSetting */
    0x02,                          /* bNumEndpoints */
    0xff,                          /* bInterfaceClass */
    0xff,                          /* bInterfaceSubClass */
    0xff,                          /* bInterfaceProtocol */
    0x02,                          /* iInterface */

    ///////////////////////////////////////
    /// endpoint descriptor
    ///////////////////////////////////////
    0x07,                         /* bLength */
    USB_DESCRIPTOR_TYPE_ENDPOINT, /* bDescriptorType */
    CDC_IN_EP,                    /* bEndpointAddress */
    0x02,                         /* bmAttributes */
    0x40, 0x00,                   /* wMaxPacketSize */
    0x01,                         /* bInterval */

    ///////////////////////////////////////
    /// endpoint descriptor
    ///////////////////////////////////////
    0x07,                         /* bLength */
    USB_DESCRIPTOR_TYPE_ENDPOINT, /* bDescriptorType */
    CDC_OUT_EP,                   /* bEndpointAddress */
    0x02,                         /* bmAttributes */
    0x40, 0x00,                   /* wMaxPacketSize */
    0x01,                         /* bInterval */

    ///////////////////////////////////////
    /// string0 descriptor
    ///////////////////////////////////////
    0x04,                       /* bLength */
    USB_DESCRIPTOR_TYPE_STRING, /* bDescriptorType */
    0x09, 0x04,                 /* wLangID0 */
    ///////////////////////////////////////
    /// string1 descriptor
    ///////////////////////////////////////
    0x0A,                       /* bLength */
    USB_DESCRIPTOR_TYPE_STRING, /* bDescriptorType */
    'F', 0x00,                  /* wcChar0 */
    'T', 0x00,                  /* wcChar1 */
    'D', 0x00,                  /* wcChar2 */
    'I', 0x00,                  /* wcChar3 */
    ///////////////////////////////////////
    /// string2 descriptor
    ///////////////////////////////////////
    0x1c,                       /* bLength */
    USB_DESCRIPTOR_TYPE_STRING, /* bDescriptorType */
    'D', 0x00,                  /* wcChar0 */
    'u', 0x00,                  /* wcChar1 */
    'a', 0x00,                  /* wcChar2 */
    'l', 0x00,                  /* wcChar3 */
    ' ', 0x00,                  /* wcChar4 */
    'R', 0x00,                  /* wcChar5 */
    'S', 0x00,                  /* wcChar6 */
    '2', 0x00,                  /* wcChar7 */
    '3', 0x00,                  /* wcChar8 */
    '2', 0x00,                  /* wcChar9 */
    '-', 0x00,                  /* wcChar10 */
    'H', 0x00,                  /* wcChar11 */
    'S', 0x00,                  /* wcChar12 */
    ///////////////////////////////////////
    /// string3 descriptor
    ///////////////////////////////////////
    0x1a,                       /* bLength */
    USB_DESCRIPTOR_TYPE_STRING, /* bDescriptorType */
    '1', 0x00,                  /* wcChar0 */
    '3', 0x00,                  /* wcChar1 */
    '3', 0x00,                  /* wcChar2 */
    '7', 0x00,                  /* wcChar3 */
    'd', 0x00,                  /* wcChar4 */
    '8', 0x00,                  /* wcChar5 */
    '0', 0x00,                  /* wcChar6 */
    '1', 0x00,                  /* wcChar7 */
    '3', 0x00,                  /* wcChar8 */
    '4', 0x00,                  /* wcChar9 */
    '7', 0x00,                  /* wcChar10 */
    'b', 0x00,                  /* wcChar11 */
    ///////////////////////////////////////
    /// device qualifier descriptor
    ///////////////////////////////////////
    0x0a,
    USB_DESCRIPTOR_TYPE_DEVICE_QUALIFIER,
    0x00,
    0x02,
    0x00,
    0x00,
    0x00,
    0x40,
    0x01,
    0x00,

    0x00
};
