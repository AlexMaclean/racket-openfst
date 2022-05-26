#include <fst/fstlib.h>

using namespace fst;

extern "C" {

    StdVectorFst *new_Fst() {
        return new StdVectorFst();
    }

    StdVectorFst *new_Fst_copy(fst::StdFst *fst) {
        return new StdVectorFst(*fst);
    }

    void Fst_AddArc(fst::StdMutableFst *fst, int state, StdArc *arc) {
        fst->AddArc(state, *arc);
    }

    int Fst_AddState(fst::StdMutableFst *fst) {
        return fst->AddState();
    }

    void Fst_AddStates(fst::StdMutableFst *fst, size_t n) {
        fst->AddStates(n);
    }

    int Fst_NumStates(fst::StdMutableFst *fst) {
        return fst->NumStates();
    }

    size_t Fst_NumArcs(fst::StdFst *fst, int state) {
        return fst->NumArcs(state);
    }

    void Fst_SetStart(fst::StdMutableFst *fst, int state) {
        fst->SetStart(state);
    }

    void Fst_SetFinal(fst::StdMutableFst *fst, int state, float weight) {
        fst->SetFinal(state, weight);
    }

    void Fst_Write(fst::StdFst *fst, char *path) {
        fst->Write(path);
    }

    int Fst_Start(fst::StdFst *fst) {
        return fst->Start();
    }

    float Fst_Final(fst::StdFst *fst, int state) {
        return fst->Final(state).Value();
    }

    fst::StdMutableFst *Fst_Read(char *path) {
        return fst::StdMutableFst::Read(path);
    }

    const SymbolTable *Fst_InputSymbols(fst::StdFst *fst) {
        return fst->InputSymbols();
    }

    const SymbolTable *Fst_OutputSymbols(fst::StdFst *fst) {
        return fst->OutputSymbols();
    }

    fst::StdMutableFst *Fst_Project(fst::StdFst *fst, ProjectType projectType) {
        return new StdVectorFst(StdProjectFst(*fst, projectType));
    }

    // Symbol Table

    size_t SymbolTable_NumSymbols(const SymbolTable *table) {
        return table->NumSymbols();
    }

    int64_t SymbolTable_GetNthKey(const SymbolTable *table, size_t pos) {
        return table->GetNthKey(pos);
    }

    const char *SymbolTable_Find(SymbolTable *table, int64_t key) {
        std::string *s = new std::string(table->Find(key));
        return s->c_str();
    }

    // String Compiler

    StdStringCompiler *new_StringCompiler() {
        return new StdStringCompiler();
    }

    fst::StdMutableFst *StringCompiler_call(StdStringCompiler *compiler, char *str, float weight) {
        StdVectorFst *fst = new StdVectorFst();
        (*compiler)(str, fst, weight);
        return fst;
    }

    // String Printer

    StdStringPrinter *new_StringPrinter() {
        return new StdStringPrinter();
    }

    const char *StringPrinter_call(StdStringPrinter *printer, fst::StdFst *fst) {
        std::string *str = new std::string();
        (*printer)(*fst, str);
        return str->c_str();
    }

    // Scripts

    fst::StdMutableFst *Fst_ShortestPath(const fst::StdFst *fst, int32_t n_shortest) {
        StdVectorFst *out_fst = new StdVectorFst();
        ShortestPath(*fst, out_fst, n_shortest);
        return out_fst;
    }

    fst::StdMutableFst *Fst_Union(const fst::StdFst *fst1, const fst::StdFst *fst2) {
        return new StdVectorFst(StdUnionFst(*fst1, *fst2));
    }

    fst::StdMutableFst *Fst_Compose(fst::StdMutableFst *ifst1, fst::StdMutableFst *ifst2) {
        StdVectorFst *ofst = new StdVectorFst();
        ArcSort(ifst1, StdOLabelCompare());
        ArcSort(ifst2, StdILabelCompare());
        Compose(*ifst1, *ifst2, ofst);
        return ofst;
    }

    fst::StdMutableFst *Fst_Cross(fst::StdFst *ifst1, fst::StdFst *ifst2) {
        StdVectorFst *ofst = new StdVectorFst();
        static const ComposeOptions opts(true, MATCH_FILTER);
        static const OutputEpsilonMapper<fst::StdArc> oeps;
        static const InputEpsilonMapper<fst::StdArc> ieps;

        Compose(StdRmEpsilonFst(ArcMapFst(*ifst1, oeps)),
                StdRmEpsilonFst(ArcMapFst(*ifst2, ieps)), ofst, opts);

        ofst->SetInputSymbols(ifst1->InputSymbols());
        ofst->SetOutputSymbols(ifst2->OutputSymbols());

        return ofst;
    }

    fst::StdMutableFst *Fst_Concat(fst::StdMutableFst *ifst1, fst::StdMutableFst *ifst2) {
        return new StdVectorFst(StdConcatFst(*ifst1, *ifst2));
    }

    fst::StdMutableFst *Fst_Difference(fst::StdMutableFst *ifst1, fst::StdMutableFst *ifst2) {
        StdVectorFst *ofst = new StdVectorFst();
        Difference(*ifst1, *ifst2, ofst);
        return ofst;
    }

    // Arc

    fst::StdArc *new_Arc(int ilabel, int olabel, float weight, int dest) {
        return new fst::StdArc(ilabel, olabel, weight, dest);
    }

    int Arc_ilabel(fst::StdArc *arc) {
        return arc->ilabel;
    }

    int Arc_olabel(fst::StdArc *arc) {
        return arc->olabel;
    }

    int Arc_weight(fst::StdArc *arc) {
        return arc->weight.Value();
    }

    int Arc_nextstate(fst::StdArc *arc) {
        return arc->nextstate;
    }

    // State Iterator

    fst::StateIterator<fst::StdFst> *new_StateIterator(fst::StdMutableFst *fst) {
        return new StateIterator<fst::StdFst>(*fst);
    }

    int StateIterator_Value(fst::StateIterator<fst::StdFst> *siter) {
        return siter->Value();
    }

    void StateIterator_Next(fst::StateIterator<fst::StdFst> *siter) {
        siter->Next();
    }

    bool StateIterator_Done(fst::StateIterator<fst::StdFst> *siter) {
        return siter->Done();
    }

    // Arc Iterator

    fst::ArcIterator<fst::StdFst> *new_ArcIterator(fst::StdMutableFst *fst, int state) {
        return new ArcIterator<fst::StdFst>(*fst, state);
    }

    fst::StdArc *ArcIterator_Value(fst::ArcIterator<fst::StdFst> *aiter) {
        return new fst::StdArc(aiter->Value());
    }

    void ArcIterator_Next(fst::ArcIterator<fst::StdFst> *aiter) {
        aiter->Next();
    }

    bool ArcIterator_Done(fst::ArcIterator<fst::StdFst> *aiter) {
        return aiter->Done();
    }

}
