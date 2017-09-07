class Qfits < Formula
  desc "Stand-alone C library offering easy access to FITS files."
  homepage "https://www.eso.org/sci/software/eclipse/qfits/"
  url "ftp://ftp.eso.org/pub/qfits/qfits-6.2.0.tar.gz"
  sha256 "3271469f8c50310ed88d1fd62a07c8bbd5b361e102def1dce3478d1a6b104b54"

  fails_with :clang do
    cause "Clang's assembler fails when both `-g` and `-O2` flags are set."
  end

  patch :DATA

  def install
    system "./configure", "--mandir=#{man}",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <stdio.h>
      #include "qfits_header.h"

      int main(int argc, char * argv[]) {
        qfits_header *qh;
        FILE *out;
        qh = qfits_header_default();
        if (qh==NULL) { return 1 ; }
        out = fopen("test.fits", "w");
        if (out==NULL) {
          qfits_header_destroy(qh);
          return 1 ;
        }
        if (qfits_header_dump(qh, out)!=0) {
          qfits_header_destroy(qh);
          return 1 ;
        }
        qfits_header_destroy(qh);
        fclose(out);
        return 0 ;
      }
    EOS
    system ENV.cc, "test.c", "-o", "test", "-I#{include}", "-L#{lib}", "-lqfits"
    system "./test"
    system "#{bin}/dfits", "test.fits"
  end
end
__END__
diff --git a/src/qfits_memory.c b/src/qfits_memory.c
index 8167d58..eddb1d3 100644
--- a/src/qfits_memory.c
+++ b/src/qfits_memory.c
@@ -308,7 +308,7 @@ void * qfits_memory_malloc(
         /* Create swap file with rights: rw-rw-rw- */
         swapfileid = ++ qfits_memory_table.file_reg ;
         fname = qfits_memory_tmpfilename(swapfileid);
-        swapfd = open(fname, O_RDWR | O_CREAT);
+        swapfd = open(fname, O_RDWR | O_CREAT, 0666);
         if (swapfd==-1) {
             fprintf(stderr, "qfits_mem: cannot create swap file\n");
             exit(-1);
