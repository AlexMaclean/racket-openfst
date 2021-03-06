#include <fst/fstlib.h>

#ifdef _WIN32
#define DllExport __declspec(dllexport)
#define TOKEN StringTokenType::UTF8
#else
#define DllExport
#define TOKEN TokenType::UTF8
#endif

using namespace fst;

// Additional Script Functions -----------------------------------------

void SetStartFinal(MutableFst<StdArc> *fst)
{
    static const auto *const kStartFinal = []
    {
        auto *sf = new VectorFst<StdArc>;
        const auto state = sf->AddState();
        sf->SetStart(state);
        sf->SetFinal(state, 0);
        return sf;
    }();
    Union(fst, *kStartFinal);
}

void ConcatRange(MutableFst<StdArc> *fst, int32_t lower, int32_t upper)
{
    if (fst->Start() == kNoStateId)
        return;

    const std::unique_ptr<const MutableFst<StdArc>> copy(fst->Copy());
    if (upper == 0)
    {
        // Infinite upper bound.
        {
            const auto size = fst->NumStates();
            const auto reserved = size * lower + size + 1;
            fst->ReserveStates(reserved);
        }
        // The last element in the concatenation is star-closed; remaining
        // concatenations are copies of the input.
        Closure(fst, CLOSURE_STAR);
        for (; lower > 0; --lower)
            Concat(*copy, fst);
    }
    else if (lower == 0)
    {
        // Finite upper bound, lower bound includes zero.
        {
            const auto reserved = fst->NumStates() * upper + upper;
            fst->ReserveStates(reserved);
        }
        for (; upper > 1; --upper)
        {
            SetStartFinal(fst);
            Concat(*copy, fst);
        }
        SetStartFinal(fst);
    }
    else
    {
        // Finite upper bound, lower bound does not include zero.
        {
            const auto size = fst->NumStates();
            const auto reserved = size * upper + upper - lower;
            fst->ReserveStates(reserved);
        }
        for (; upper > lower; --upper)
        {
            SetStartFinal(fst);
            Concat(*copy, fst);
        }
        for (; lower > 1; --lower)
            Concat(*copy, fst);
    }
}

// API -----------------------------------------------------------------

extern "C"
{

    DllExport StdVectorFst *new_Fst()
    {
        return new StdVectorFst();
    }

    DllExport StdVectorFst *new_Fst_copy(fst::StdFst *fst)
    {
        return new StdVectorFst(*fst);
    }

    DllExport void Fst_AddArc(fst::StdMutableFst *fst, int state, StdArc *arc)
    {
        fst->AddArc(state, *arc);
    }

    DllExport int Fst_AddState(fst::StdMutableFst *fst)
    {
        return fst->AddState();
    }

    DllExport int Fst_NumStates(fst::StdMutableFst *fst)
    {
        return fst->NumStates();
    }

    DllExport size_t Fst_NumArcs(fst::StdFst *fst, int state)
    {
        return fst->NumArcs(state);
    }

    DllExport void Fst_SetStart(fst::StdMutableFst *fst, int state)
    {
        fst->SetStart(state);
    }

    DllExport void Fst_SetFinal(fst::StdMutableFst *fst, int state, float weight)
    {
        fst->SetFinal(state, weight);
    }

    DllExport void Fst_Write(fst::StdFst *fst, char *path)
    {
        fst->Write(path);
    }

    DllExport fst::StdMutableFst *Fst_Read(char *path)
    {
        return fst::StdVectorFst::Read(path);
    }

    DllExport int Fst_Start(fst::StdFst *fst)
    {
        return fst->Start();
    }

    DllExport float Fst_Final(fst::StdFst *fst, int state)
    {
        return fst->Final(state).Value();
    }

    DllExport const SymbolTable *Fst_InputSymbols(fst::StdFst *fst)
    {
        return fst->InputSymbols();
    }

    DllExport const SymbolTable *Fst_OutputSymbols(fst::StdFst *fst)
    {
        return fst->OutputSymbols();
    }

    DllExport fst::StdMutableFst *Fst_Project(fst::StdFst *fst, ProjectType projectType)
    {
        return new StdVectorFst(StdProjectFst(*fst, projectType));
    }

    DllExport void delete_Fst(fst::StdMutableFst *fst)
    {
        delete fst;
    }

    DllExport bool Fst_Verify(const fst::StdFst *fst)
    {
        return Verify(*fst);
    }

    // Symbol Table -------------------------------------------------------

    DllExport size_t SymbolTable_NumSymbols(const SymbolTable *table)
    {
        return table->NumSymbols();
    }

    DllExport int64_t SymbolTable_GetNthKey(const SymbolTable *table, size_t pos)
    {
        return table->GetNthKey(pos);
    }

    DllExport const char *SymbolTable_Find(SymbolTable *table, int64_t key)
    {
        std::string *s = new std::string(table->Find(key));
        return s->c_str();
    }

    // String Compiler -------------------------------------------------------

    DllExport StringCompiler<StdArc> *new_StringCompiler()
    {
        return new StringCompiler<StdArc>(TOKEN);
    }

    DllExport fst::StdMutableFst *StringCompiler_call(StringCompiler<StdArc> *compiler, char *str, float weight)
    {
        StdVectorFst *fst = new StdVectorFst();
        (*compiler)(str, fst, weight);
        return fst;
    }

    DllExport void delete_StringCompiler(StringCompiler<StdArc> *compiler)
    {
        delete compiler;
    }

    // String Printer -------------------------------------------------------

    DllExport StringPrinter<StdArc> *new_StringPrinter()
    {
        return new StringPrinter<StdArc>(TOKEN);
    }

    DllExport const char *StringPrinter_call(StringPrinter<StdArc> *printer, fst::StdFst *fst)
    {
        std::string *str = new std::string();
        (*printer)(*fst, str);
        return str->c_str();
    }

    DllExport void delete_StringPrinter(StringPrinter<StdArc> *printer)
    {
        delete printer;
    }

    // Scripts -------------------------------------------------------

    DllExport fst::StdMutableFst *Fst_ShortestPath(const fst::StdFst *fst, int32_t n_shortest)
    {
        StdVectorFst *out_fst = new StdVectorFst();
        ShortestPath(*fst, out_fst, n_shortest);
        return out_fst;
    }

    DllExport fst::StdMutableFst *Fst_Union(const fst::StdFst *fst1, const fst::StdFst *fst2)
    {
        return new StdVectorFst(StdUnionFst(*fst1, *fst2));
    }

    DllExport fst::StdMutableFst *Fst_Compose(fst::StdMutableFst *ifst1, fst::StdMutableFst *ifst2)
    {
        StdVectorFst *ofst = new StdVectorFst();
        ArcSort(ifst1, StdOLabelCompare());
        ArcSort(ifst2, StdILabelCompare());
        Compose(*ifst1, *ifst2, ofst);
        return ofst;
    }

    DllExport fst::StdMutableFst *Fst_Cross(fst::StdFst *ifst1, fst::StdFst *ifst2)
    {
        StdVectorFst *ofst = new StdVectorFst();
        static const ComposeOptions opts(true, MATCH_FILTER);
        static const OutputEpsilonMapper<fst::StdArc> oeps;
        static const InputEpsilonMapper<fst::StdArc> ieps;

        Compose(StdRmEpsilonFst(ArcMapFst<StdArc, StdArc, OutputEpsilonMapper<StdArc>>(*ifst1, oeps)),
                StdRmEpsilonFst(ArcMapFst<StdArc, StdArc, InputEpsilonMapper<StdArc>>(*ifst2, ieps)), ofst, opts);

        ofst->SetInputSymbols(ifst1->InputSymbols());
        ofst->SetOutputSymbols(ifst2->OutputSymbols());

        return ofst;
    }

    DllExport fst::StdMutableFst *Fst_Concat(fst::StdMutableFst *ifst1, fst::StdMutableFst *ifst2)
    {
        return new StdVectorFst(StdConcatFst(*ifst1, *ifst2));
    }

    DllExport fst::StdMutableFst *Fst_Difference(fst::StdMutableFst *ifst1, fst::StdMutableFst *ifst2)
    {
        fst::StdVectorFst fst2 = StdVectorFst(*ifst2);
        fst::StdVectorFst ofst2;
        RmEpsilon(&fst2);
        Determinize(fst2, &ofst2);

        static const ILabelCompare<fst::StdArc> comp;
        ArcSort(&ofst2, comp);
        StdVectorFst *ofst = new StdVectorFst();
        Difference(*ifst1, ofst2, ofst);
        return ofst;
    }

    DllExport fst::StdMutableFst *Fst_Closure(fst::StdMutableFst *fst, int32_t lower, int32_t upper)
    {
        StdVectorFst *ofst = new StdVectorFst(*fst);
        ConcatRange(ofst, lower, upper);
        return ofst;
    }

    DllExport fst::StdMutableFst *Fst_Invert(fst::StdMutableFst *fst)
    {
        return new StdVectorFst(StdInvertFst(*fst));
    }

    DllExport fst::StdMutableFst *Fst_Reverse(fst::StdMutableFst *ifst)
    {
        StdVectorFst *ofst = new StdVectorFst();
        Reverse(*ifst, ofst);
        return ofst;
    }

    DllExport fst::StdMutableFst *Fst_Optimize(fst::StdMutableFst *ifst)
    {
        StdVectorFst *ofst = new StdVectorFst(*ifst);
        RmEpsilon(ofst);
        Minimize(ofst);
        return ofst;
    }

    // Arc -------------------------------------------------------

    DllExport fst::StdArc *new_Arc(int ilabel, int olabel, float weight, int dest)
    {
        return new fst::StdArc(ilabel, olabel, weight, dest);
    }

    DllExport int Arc_ilabel(fst::StdArc *arc)
    {
        return arc->ilabel;
    }

    DllExport int Arc_olabel(fst::StdArc *arc)
    {
        return arc->olabel;
    }

    DllExport float Arc_weight(fst::StdArc *arc)
    {
        return arc->weight.Value();
    }

    DllExport int Arc_nextstate(fst::StdArc *arc)
    {
        return arc->nextstate;
    }

    DllExport void delete_Arc(fst::StdArc *arc)
    {
        delete arc;
    }

    // State Iterator -------------------------------------------------------

    DllExport fst::StateIterator<fst::StdFst> *new_StateIterator(fst::StdMutableFst *fst)
    {
        return new StateIterator<fst::StdFst>(*fst);
    }

    DllExport int StateIterator_Value(fst::StateIterator<fst::StdFst> *siter)
    {
        return siter->Value();
    }

    DllExport void StateIterator_Next(fst::StateIterator<fst::StdFst> *siter)
    {
        siter->Next();
    }

    DllExport bool StateIterator_Done(fst::StateIterator<fst::StdFst> *siter)
    {
        return siter->Done();
    }

    DllExport void delete_StateIterator(fst::StateIterator<fst::StdFst> *siter)
    {
        delete siter;
    }

    // Arc Iterator -------------------------------------------------------

    DllExport fst::ArcIterator<fst::StdFst> *new_ArcIterator(fst::StdMutableFst *fst, int state)
    {
        return new ArcIterator<fst::StdFst>(*fst, state);
    }

    DllExport fst::StdArc *ArcIterator_Value(fst::ArcIterator<fst::StdFst> *aiter)
    {
        return new fst::StdArc(aiter->Value());
    }

    DllExport void ArcIterator_Next(fst::ArcIterator<fst::StdFst> *aiter)
    {
        aiter->Next();
    }

    DllExport bool ArcIterator_Done(fst::ArcIterator<fst::StdFst> *aiter)
    {
        return aiter->Done();
    }

    DllExport void delete_ArcIterator(fst::ArcIterator<fst::StdFst> *aiter)
    {
        delete aiter;
    }
}
