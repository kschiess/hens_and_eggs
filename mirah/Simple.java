// Generated from simple.mirah
public class Simple extends java.lang.Object {
  public static void main(java.lang.String[] argv) {
    java.util.Iterator __xform_tmp_1 = null;
    java.lang.Object el = null;
    __xform_tmp_1 = java.util.Collections.unmodifiableList(java.util.Arrays.asList(1, 2, 3)).iterator();
    label1:
    while (__xform_tmp_1.hasNext()) {
      el = __xform_tmp_1.next();
      label2:
       {
        java.io.PrintStream temp$3 = java.lang.System.out;
        temp$3.println(el);
      }
    }
  }
}
