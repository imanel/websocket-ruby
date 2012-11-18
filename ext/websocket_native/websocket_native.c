#include <ruby.h>

VALUE WebSocket = Qnil;
VALUE WebSocketFrame = Qnil;
VALUE WebSocketFrameData = Qnil;

void Init_websocket_native();
VALUE method_websocket_frame_data_mask_native(VALUE self, VALUE payload, VALUE mask);

void Init_websocket_native() {
  WebSocket = rb_define_module("WebSocket");
  WebSocketFrame = rb_define_module_under(WebSocket, "Frame");
  WebSocketFrameData = rb_define_class_under(WebSocketFrame, "Data", rb_cString);
  rb_define_method(WebSocketFrameData, "mask_native", method_websocket_frame_data_mask_native, 2);
}

VALUE method_websocket_frame_data_mask_native(VALUE self, VALUE payload, VALUE mask) {
  int n = RARRAY_LEN(payload), i, p, m;
  VALUE unmasked = rb_ary_new2(n);

  int mask_array[] = {
    NUM2INT(rb_ary_entry(mask, 0)),
    NUM2INT(rb_ary_entry(mask, 1)),
    NUM2INT(rb_ary_entry(mask, 2)),
    NUM2INT(rb_ary_entry(mask, 3))
  };

  for (i = 0; i < n; i++) {
    p = NUM2INT(rb_ary_entry(payload, i));
    m = mask_array[i % 4];
    rb_ary_store(unmasked, i, INT2NUM(p ^ m));
  }
  return unmasked;
}
