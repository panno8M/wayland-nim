# Generated by wayland-nim-scanner 1.23.1
{.warning[UnusedImport]:off.}
import wayland/native/server
import wayland/native/common
import code
export code

## The ext_workspace_v1 SERVER protocol
## ####################################
## 
## Interfaces
## ==========
## 
## * ext_workspace_manager_v1
## * ext_workspace_group_handle_v1
## * ext_workspace_handle_v1
## 
## Copyright
## =========
## 
## Copyright © 2019 Christopher Billington
## Copyright © 2020 Ilia Bozhinov
## Copyright © 2022 Victoria Brekenfeld
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

type ExtWorkspaceManagerV1Interface* = object
  commit*: proc(
    client: ptr Client;
    resource: ptr Resource;
  ) {.nimcall.}
  stop*: proc(
    client: ptr Client;
    resource: ptr Resource;
  ) {.nimcall.}

proc extWorkspaceManagerV1SendWorkspaceGroup*(resource: ptr Resource; workspaceGroup: ptr Resource) {.inline, exportc: "ext_workspace_manager_v1_send_workspace_group".} =
  ## Sends an workspace_group event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtWorkspaceManagerV1Event_workspace_group.ord, workspaceGroup)

proc extWorkspaceManagerV1SendWorkspace*(resource: ptr Resource; workspace: ptr Resource) {.inline, exportc: "ext_workspace_manager_v1_send_workspace".} =
  ## Sends an workspace event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtWorkspaceManagerV1Event_workspace.ord, workspace)

proc extWorkspaceManagerV1SendDone*(resource: ptr Resource) {.inline, exportc: "ext_workspace_manager_v1_send_done".} =
  ## Sends an done event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtWorkspaceManagerV1Event_done.ord)

proc extWorkspaceManagerV1SendFinished*(resource: ptr Resource) {.inline, exportc: "ext_workspace_manager_v1_send_finished".} =
  ## Sends an finished event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtWorkspaceManagerV1Event_finished.ord)

type ExtWorkspaceGroupHandleV1Interface* = object
  createWorkspace*: proc(
    client: ptr Client;
    resource: ptr Resource;
    workspace: cstring;
  ) {.nimcall.}
  destroy*: proc(
    client: ptr Client;
    resource: ptr Resource;
  ) {.nimcall.}

proc extWorkspaceGroupHandleV1SendCapabilities*(resource: ptr Resource; capabilities: uint32) {.inline, exportc: "ext_workspace_group_handle_v1_send_capabilities".} =
  ## Sends an capabilities event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  ## * *capabilities*: capabilities
  resource.post_event(ExtWorkspaceGroupHandleV1Event_capabilities.ord, capabilities)

proc extWorkspaceGroupHandleV1SendOutputEnter*(resource: ptr Resource; output: ptr Resource) {.inline, exportc: "ext_workspace_group_handle_v1_send_output_enter".} =
  ## Sends an output_enter event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtWorkspaceGroupHandleV1Event_output_enter.ord, output)

proc extWorkspaceGroupHandleV1SendOutputLeave*(resource: ptr Resource; output: ptr Resource) {.inline, exportc: "ext_workspace_group_handle_v1_send_output_leave".} =
  ## Sends an output_leave event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtWorkspaceGroupHandleV1Event_output_leave.ord, output)

proc extWorkspaceGroupHandleV1SendWorkspaceEnter*(resource: ptr Resource; workspace: ptr Resource) {.inline, exportc: "ext_workspace_group_handle_v1_send_workspace_enter".} =
  ## Sends an workspace_enter event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtWorkspaceGroupHandleV1Event_workspace_enter.ord, workspace)

proc extWorkspaceGroupHandleV1SendWorkspaceLeave*(resource: ptr Resource; workspace: ptr Resource) {.inline, exportc: "ext_workspace_group_handle_v1_send_workspace_leave".} =
  ## Sends an workspace_leave event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtWorkspaceGroupHandleV1Event_workspace_leave.ord, workspace)

proc extWorkspaceGroupHandleV1SendRemoved*(resource: ptr Resource) {.inline, exportc: "ext_workspace_group_handle_v1_send_removed".} =
  ## Sends an removed event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtWorkspaceGroupHandleV1Event_removed.ord)

type ExtWorkspaceHandleV1Interface* = object
  destroy*: proc(
    client: ptr Client;
    resource: ptr Resource;
  ) {.nimcall.}
  activate*: proc(
    client: ptr Client;
    resource: ptr Resource;
  ) {.nimcall.}
  deactivate*: proc(
    client: ptr Client;
    resource: ptr Resource;
  ) {.nimcall.}
  assign*: proc(
    client: ptr Client;
    resource: ptr Resource;
    workspaceGroup: ptr Resource;
  ) {.nimcall.}
  remove*: proc(
    client: ptr Client;
    resource: ptr Resource;
  ) {.nimcall.}

proc extWorkspaceHandleV1SendId*(resource: ptr Resource; id: cstring) {.inline, exportc: "ext_workspace_handle_v1_send_id".} =
  ## Sends an id event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtWorkspaceHandleV1Event_id.ord, id)

proc extWorkspaceHandleV1SendName*(resource: ptr Resource; name: cstring) {.inline, exportc: "ext_workspace_handle_v1_send_name".} =
  ## Sends an name event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtWorkspaceHandleV1Event_name.ord, name)

proc extWorkspaceHandleV1SendCoordinates*(resource: ptr Resource; coordinates: ptr Array) {.inline, exportc: "ext_workspace_handle_v1_send_coordinates".} =
  ## Sends an coordinates event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtWorkspaceHandleV1Event_coordinates.ord, coordinates)

proc extWorkspaceHandleV1SendState*(resource: ptr Resource; state: uint32) {.inline, exportc: "ext_workspace_handle_v1_send_state".} =
  ## Sends an state event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtWorkspaceHandleV1Event_state.ord, state)

proc extWorkspaceHandleV1SendCapabilities*(resource: ptr Resource; capabilities: uint32) {.inline, exportc: "ext_workspace_handle_v1_send_capabilities".} =
  ## Sends an capabilities event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  ## * *capabilities*: capabilities
  resource.post_event(ExtWorkspaceHandleV1Event_capabilities.ord, capabilities)

proc extWorkspaceHandleV1SendRemoved*(resource: ptr Resource) {.inline, exportc: "ext_workspace_handle_v1_send_removed".} =
  ## Sends an removed event to the client owning the resource.
  ## 
  ## **params**:
  ## * *resource*: The client's resource
  resource.post_event(ExtWorkspaceHandleV1Event_removed.ord)

