# Generated by wayland-nim-scanner 1.23.1
{.warning[UnusedImport]:off.}
import wayland/native/server
import wayland/native/common
import code
export code

## The ext_foreign_toplevel_list_v1 SERVER protocol
## ################################################
## 
## Interfaces
## ==========
## 
## * ext_foreign_toplevel_list_v1
## * ext_foreign_toplevel_handle_v1
## 
## Copyright
## =========
## 
## Copyright © 2018 Ilia Bozhinov
## Copyright © 2020 Isaac Freund
## Copyright © 2022 wb9688
## Copyright © 2023 i509VCB
## 
## Permission to use, copy, modify, distribute, and sell this
## software and its documentation for any purpose is hereby granted
## without fee, provided that the above copyright notice appear in
## all copies and that both that copyright notice and this permission
## notice appear in supporting documentation, and that the name of
## the copyright holders not be used in advertising or publicity
## pertaining to distribution of the software without specific,
## written prior permission.  The copyright holders make no
## representations about the suitability of this software for any
## purpose.  It is provided "as is" without express or implied
## warranty.
## 
## THE COPYRIGHT HOLDERS DISCLAIM ALL WARRANTIES WITH REGARD TO THIS
## SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
## FITNESS, IN NO EVENT SHALL THE COPYRIGHT HOLDERS BE LIABLE FOR ANY
## SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
## WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN
## AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
## ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
## THIS SOFTWARE.
## 

type ExtForeignToplevelListV1Interface* = object
  stop*: proc(
    client: ptr Client;
    resource: ptr Resource;
  ) {.nimcall.}
  destroy*: proc(
    client: ptr Client;
    resource: ptr Resource;
  ) {.nimcall.}

proc extForeignToplevelListV1SendToplevel*(resource: ptr Resource; toplevel: ptr Resource) {.inline, exportc: "ext_foreign_toplevel_list_v1_send_toplevel".} =
  ## Sends an toplevel event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtForeignToplevelListV1Event_toplevel.ord, toplevel)

proc extForeignToplevelListV1SendFinished*(resource: ptr Resource) {.inline, exportc: "ext_foreign_toplevel_list_v1_send_finished".} =
  ## Sends an finished event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtForeignToplevelListV1Event_finished.ord)

type ExtForeignToplevelHandleV1Interface* = object
  destroy*: proc(
    client: ptr Client;
    resource: ptr Resource;
  ) {.nimcall.}

proc extForeignToplevelHandleV1SendClosed*(resource: ptr Resource) {.inline, exportc: "ext_foreign_toplevel_handle_v1_send_closed".} =
  ## Sends an closed event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtForeignToplevelHandleV1Event_closed.ord)

proc extForeignToplevelHandleV1SendDone*(resource: ptr Resource) {.inline, exportc: "ext_foreign_toplevel_handle_v1_send_done".} =
  ## Sends an done event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtForeignToplevelHandleV1Event_done.ord)

proc extForeignToplevelHandleV1SendTitle*(resource: ptr Resource; title: cstring) {.inline, exportc: "ext_foreign_toplevel_handle_v1_send_title".} =
  ## Sends an title event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtForeignToplevelHandleV1Event_title.ord, title)

proc extForeignToplevelHandleV1SendAppId*(resource: ptr Resource; appId: cstring) {.inline, exportc: "ext_foreign_toplevel_handle_v1_send_app_id".} =
  ## Sends an app_id event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtForeignToplevelHandleV1Event_app_id.ord, appId)

proc extForeignToplevelHandleV1SendIdentifier*(resource: ptr Resource; identifier: cstring) {.inline, exportc: "ext_foreign_toplevel_handle_v1_send_identifier".} =
  ## Sends an identifier event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtForeignToplevelHandleV1Event_identifier.ord, identifier)

