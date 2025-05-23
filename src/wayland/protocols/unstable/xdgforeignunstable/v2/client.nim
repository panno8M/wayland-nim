# Generated by wayland-nim-scanner 1.23.1
{.warning[UnusedImport]:off.}
import wayland/native/client
import wayland/native/common
import code
export code

## The xdg_foreign_unstable_v2 CLIENT protocol
## ###########################################
## 
## Interfaces
## ==========
## 
## * zxdg_exporter_v2
## * zxdg_importer_v2
## * zxdg_exported_v2
## * zxdg_imported_v2
## 
## Copyright
## =========
## 
## Copyright © 2015-2016 Red Hat Inc.
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

proc setUserData*(zxdgExporterV2: ptr ZxdgExporterV2; userData: pointer) {.inline.} =
  cast[ptr Proxy](zxdgExporterV2).set_user_data(user_data)
proc getUserData*(zxdgExporterV2: ptr ZxdgExporterV2): pointer {.inline.} =
  cast[ptr Proxy](zxdgExporterV2).get_user_data()
proc getVersion*(zxdgExporterV2: ptr ZxdgExporterV2): uint32 {.inline.} =
  cast[ptr Proxy](zxdgExporterV2).get_version()
proc destroy*(zxdgExporterV2: ptr ZxdgExporterV2) {.inline.} =
  ## destroy the xdg_exporter object
  ## 
  ## Notify the compositor that the xdg_exporter object will no longer be
  ## 	used.
  ## 
  cast[ptr Proxy](zxdgExporterV2).marshal_flags(ZxdgExporterV2Request_destroy.ord, nil, cast[ptr Proxy](zxdgExporterV2).get_version(), WL_MARSHAL_FLAG_DESTROY)
proc exportToplevel*(zxdgExporterV2: ptr ZxdgExporterV2; surface: ptr Surface): ptr ZxdgExportedV2 {.inline.} =
  ## export a toplevel surface
  ## 
  ## The export_toplevel request exports the passed surface so that it can later be
  ## 	imported via xdg_importer. When called, a new xdg_exported object will
  ## 	be created and xdg_exported.handle will be sent immediately. See the
  ## 	corresponding interface and event for details.
  ## 
  ## 	A surface may be exported multiple times, and each exported handle may
  ## 	be used to create an xdg_imported multiple times. Only xdg_toplevel
  ## equivalent surfaces may be exported, otherwise an invalid_surface
  ## protocol error is sent.
  ## 
  cast[ptr ZxdgExportedV2](cast[ptr Proxy](zxdgExporterV2).marshal_flags(ZxdgExporterV2Request_export_toplevel.ord, addr zxdg_exported_v2_interface, cast[ptr Proxy](zxdgExporterV2).get_version(), 0, nil, surface))
proc setUserData*(zxdgImporterV2: ptr ZxdgImporterV2; userData: pointer) {.inline.} =
  cast[ptr Proxy](zxdgImporterV2).set_user_data(user_data)
proc getUserData*(zxdgImporterV2: ptr ZxdgImporterV2): pointer {.inline.} =
  cast[ptr Proxy](zxdgImporterV2).get_user_data()
proc getVersion*(zxdgImporterV2: ptr ZxdgImporterV2): uint32 {.inline.} =
  cast[ptr Proxy](zxdgImporterV2).get_version()
proc destroy*(zxdgImporterV2: ptr ZxdgImporterV2) {.inline.} =
  ## destroy the xdg_importer object
  ## 
  ## Notify the compositor that the xdg_importer object will no longer be
  ## 	used.
  ## 
  cast[ptr Proxy](zxdgImporterV2).marshal_flags(ZxdgImporterV2Request_destroy.ord, nil, cast[ptr Proxy](zxdgImporterV2).get_version(), WL_MARSHAL_FLAG_DESTROY)
proc importToplevel*(zxdgImporterV2: ptr ZxdgImporterV2; handle: cstring): ptr ZxdgImportedV2 {.inline.} =
  ## import a toplevel surface
  ## 
  ## The import_toplevel request imports a surface from any client given a handle
  ## 	retrieved by exporting said surface using xdg_exporter.export_toplevel.
  ## 	When called, a new xdg_imported object will be created. This new object
  ## 	represents the imported surface, and the importing client can
  ## 	manipulate its relationship using it. See xdg_imported for details.
  ## 
  cast[ptr ZxdgImportedV2](cast[ptr Proxy](zxdgImporterV2).marshal_flags(ZxdgImporterV2Request_import_toplevel.ord, addr zxdg_imported_v2_interface, cast[ptr Proxy](zxdgImporterV2).get_version(), 0, nil, handle))
type ZxdgExportedV2Listener* = object
  handle*: proc(
    data: pointer;
    zxdgExportedV2: ptr ZxdgExportedV2;
    handle: cstring;
  ) {.nimcall.}
proc addListener*(zxdgExportedV2: ptr ZxdgExportedV2; listener: ptr ZxdgExportedV2Listener; data: pointer): int {.inline.} =
  cast[ptr Proxy](zxdgExportedV2).add_listener(listener, data)

proc setUserData*(zxdgExportedV2: ptr ZxdgExportedV2; userData: pointer) {.inline.} =
  cast[ptr Proxy](zxdgExportedV2).set_user_data(user_data)
proc getUserData*(zxdgExportedV2: ptr ZxdgExportedV2): pointer {.inline.} =
  cast[ptr Proxy](zxdgExportedV2).get_user_data()
proc getVersion*(zxdgExportedV2: ptr ZxdgExportedV2): uint32 {.inline.} =
  cast[ptr Proxy](zxdgExportedV2).get_version()
proc destroy*(zxdgExportedV2: ptr ZxdgExportedV2) {.inline.} =
  ## unexport the exported surface
  ## 
  ## Revoke the previously exported surface. This invalidates any
  ## 	relationship the importer may have set up using the xdg_imported created
  ## 	given the handle sent via xdg_exported.handle.
  ## 
  cast[ptr Proxy](zxdgExportedV2).marshal_flags(ZxdgExportedV2Request_destroy.ord, nil, cast[ptr Proxy](zxdgExportedV2).get_version(), WL_MARSHAL_FLAG_DESTROY)
type ZxdgImportedV2Listener* = object
  destroyed*: proc(
    data: pointer;
    zxdgImportedV2: ptr ZxdgImportedV2;
  ) {.nimcall.}
proc addListener*(zxdgImportedV2: ptr ZxdgImportedV2; listener: ptr ZxdgImportedV2Listener; data: pointer): int {.inline.} =
  cast[ptr Proxy](zxdgImportedV2).add_listener(listener, data)

proc setUserData*(zxdgImportedV2: ptr ZxdgImportedV2; userData: pointer) {.inline.} =
  cast[ptr Proxy](zxdgImportedV2).set_user_data(user_data)
proc getUserData*(zxdgImportedV2: ptr ZxdgImportedV2): pointer {.inline.} =
  cast[ptr Proxy](zxdgImportedV2).get_user_data()
proc getVersion*(zxdgImportedV2: ptr ZxdgImportedV2): uint32 {.inline.} =
  cast[ptr Proxy](zxdgImportedV2).get_version()
proc destroy*(zxdgImportedV2: ptr ZxdgImportedV2) {.inline.} =
  ## destroy the xdg_imported object
  ## 
  ## Notify the compositor that it will no longer use the xdg_imported
  ## 	object. Any relationship that may have been set up will at this point
  ## 	be invalidated.
  ## 
  cast[ptr Proxy](zxdgImportedV2).marshal_flags(ZxdgImportedV2Request_destroy.ord, nil, cast[ptr Proxy](zxdgImportedV2).get_version(), WL_MARSHAL_FLAG_DESTROY)
proc setParentOf*(zxdgImportedV2: ptr ZxdgImportedV2; surface: ptr Surface) {.inline.} =
  ## set as the parent of some surface
  ## 
  ## Set the imported surface as the parent of some surface of the client.
  ## The passed surface must be an xdg_toplevel equivalent, otherwise an
  ## invalid_surface protocol error is sent. Calling this function sets up
  ## a surface to surface relation with the same stacking and positioning
  ## semantics as xdg_toplevel.set_parent.
  ## 
  cast[ptr Proxy](zxdgImportedV2).marshal_flags(ZxdgImportedV2Request_set_parent_of.ord, nil, cast[ptr Proxy](zxdgImportedV2).get_version(), 0, surface)
