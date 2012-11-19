package org.imanel.websocket;

import java.lang.Long;
import java.io.IOException;

import org.jruby.Ruby;
import org.jruby.RubyArray;
import org.jruby.RubyClass;
import org.jruby.RubyFixnum;
import org.jruby.RubyModule;
import org.jruby.RubyObject;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.load.BasicLibraryService;

public class WebSocketNativeService implements BasicLibraryService {
  private Ruby runtime;

  public boolean basicLoad(Ruby runtime) throws IOException {
    this.runtime = runtime;
    RubyModule webSocket = runtime.defineModule("WebSocket");
    RubyModule webSocketNative = webSocket.defineModuleUnder("Native");

    RubyClass webSocketNativeData = webSocketNative.defineClassUnder("Data", runtime.getObject(), new ObjectAllocator() {
      public IRubyObject allocate(Ruby runtime, RubyClass rubyClass) {
        return new WebSocketNativeData(runtime, rubyClass);
      }
    });

    webSocketNativeData.defineAnnotatedMethods(WebSocketNativeData.class);
    return true;
  }

  public class WebSocketNativeData extends RubyObject {
    public WebSocketNativeData(final Ruby runtime, RubyClass rubyClass) {
      super(runtime, rubyClass);
    }

    @JRubyMethod
    public IRubyObject mask(ThreadContext context, IRubyObject payload, IRubyObject mask) {
      int n = ((RubyArray)payload).getLength(), i;
      long p, m;
      RubyArray unmasked = RubyArray.newArray(runtime, n);

      long[] maskArray = {
        (Long)((RubyArray)mask).get(0),
        (Long)((RubyArray)mask).get(1),
        (Long)((RubyArray)mask).get(2),
        (Long)((RubyArray)mask).get(3)
      };

      for (i = 0; i < n; i++) {
        p = (Long)((RubyArray)payload).get(i);
        m = maskArray[i % 4];
        unmasked.set(i, p ^ m);
      }
      return unmasked;
    }
  }
}
