# Generated by wayland-nim-scanner 1.23.1
{.warning[UnusedImport]:off.}
import wayland/native/server
import wayland/native/common
import code
export code

## The wp_primary_selection_unstable_v1 SERVER protocol
## ####################################################
## 
## Interfaces
## ==========
## 
## * zwp_primary_selection_device_manager_v1
## * zwp_primary_selection_device_v1
## * zwp_primary_selection_offer_v1
## * zwp_primary_selection_source_v1
## 
## Copyright
## =========
## 
## Copyright © 2015, 2016 Red Hat
## 
## Permission is hereby granted, free of charge, to any person obtaining a
## copy of this software and associated documentation files (the "Software"),
## to deal in the Software without restriction, including without limitation
## the rights to use, copy, modify, merge, publish, distribute, sublicense,
## and/or sell copies of the Software, and to permit persons to whom the
## Software is furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice (including the next
## paragraph) shall be included in all copies or substantial portions of the
## Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
## THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
## FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
## DEALINGS IN THE SOFTWARE.
## 

type ZwpPrimarySelectionDeviceManagerV1Interface* = object
  createSource*: proc(
    client: ptr Client;
    resource: ptr Resource;
    id: uint32;
  ) {.nimcall.}
  getDevice*: proc(
    client: ptr Client;
    resource: ptr Resource;
    id: uint32;
    seat: ptr Resource;
  ) {.nimcall.}
  destroy*: proc(
    client: ptr Client;
    resource: ptr Resource;
  ) {.nimcall.}

type ZwpPrimarySelectionDeviceV1Interface* = object
  setSelection*: proc(
    client: ptr Client;
    resource: ptr Resource;
    source: ptr Resource;
    serial: uint32;
  ) {.nimcall.}
  destroy*: proc(
    client: ptr Client;
    resource: ptr Resource;
  ) {.nimcall.}

proc zwpPrimarySelectionDeviceV1SendDataOffer*(resource: ptr Resource; offer: ptr Resource) {.inline, exportc: "zwp_primary_selection_device_v1_send_data_offer".} =
  ## Sends an data_offer event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ZwpPrimarySelectionDeviceV1Event_data_offer.ord, offer)

proc zwpPrimarySelectionDeviceV1SendSelection*(resource: ptr Resource; id: ptr Resource) {.inline, exportc: "zwp_primary_selection_device_v1_send_selection".} =
  ## Sends an selection event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ZwpPrimarySelectionDeviceV1Event_selection.ord, id)

type ZwpPrimarySelectionOfferV1Interface* = object
  receive*: proc(
    client: ptr Client;
    resource: ptr Resource;
    mimeType: cstring;
    fd: int32;
  ) {.nimcall.}
  destroy*: proc(
    client: ptr Client;
    resource: ptr Resource;
  ) {.nimcall.}

proc zwpPrimarySelectionOfferV1SendOffer*(resource: ptr Resource; mimeType: cstring) {.inline, exportc: "zwp_primary_selection_offer_v1_send_offer".} =
  ## Sends an offer event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ZwpPrimarySelectionOfferV1Event_offer.ord, mimeType)

type ZwpPrimarySelectionSourceV1Interface* = object
  offer*: proc(
    client: ptr Client;
    resource: ptr Resource;
    mimeType: cstring;
  ) {.nimcall.}
  destroy*: proc(
    client: ptr Client;
    resource: ptr Resource;
  ) {.nimcall.}

proc zwpPrimarySelectionSourceV1SendSend*(resource: ptr Resource; mimeType: cstring; fd: int32) {.inline, exportc: "zwp_primary_selection_source_v1_send_send".} =
  ## Sends an send event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ZwpPrimarySelectionSourceV1Event_send.ord, mimeType, fd)

proc zwpPrimarySelectionSourceV1SendCancelled*(resource: ptr Resource) {.inline, exportc: "zwp_primary_selection_source_v1_send_cancelled".} =
  ## Sends an cancelled event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ZwpPrimarySelectionSourceV1Event_cancelled.ord)

