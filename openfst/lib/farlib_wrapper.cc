#include <fst/extensions/far/farlib.h>
#include <fst/fstlib.h>

using namespace fst;

extern "C" {

    void VectorFst_AddStates(fst::StdMutableFst *fst) {
        FarReader<fst::StdArc> *f = FarReader<fst::StdArc>::Open("in.far");
        f->GetFst()
    }

}
