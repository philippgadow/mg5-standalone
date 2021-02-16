/*
Simple macro showing how to access branches from the delphes output root file,
loop over events, store histograms in a root file and print them as image files.
root -l bsm4tops.C'("delphes_output.root")'
*/

#include "TH1.h"
#include "TSystem.h"

#ifdef __CLING__
R__LOAD_LIBRARY(libDelphes)
#include "classes/DelphesClasses.h"
#include "external/ExRootAnalysis/ExRootTreeReader.h"
#include "external/ExRootAnalysis/ExRootResult.h"
#endif

//------------------------------------------------------------------------------

struct MyPlots {
  TH1 *fJetPT[2];
  TH1 *fJetM;

};

//------------------------------------------------------------------------------

class ExRootResult;
class ExRootTreeReader;

//------------------------------------------------------------------------------

void BookHistograms(ExRootResult *result, MyPlots *plots) {

  // book 2 histograms for PT of 1st and 2nd leading jets
  plots->fJetPT[0] = result->AddHist1D(
    "jet_pt_0", "leading jet P_{T}",
    "jet P_{T}, GeV/c", "number of jets",
    50, 0.0, 500.0);

  plots->fJetPT[1] = result->AddHist1D(
    "jet_pt_1", "2nd leading jet P_{T}",
    "jet P_{T}, GeV/c", "number of jets",
    50, 0.0, 500.0);

  plots->fJetM = result->AddHist1D(
    "jet_m", "leading jet m",
    "jet m, GeV/c", "number of jets",
    50, 0.0, 500.0);

  plots->fJetPT[0]->SetLineColor(kRed);
  plots->fJetPT[1]->SetLineColor(kBlue);
}

//------------------------------------------------------------------------------

void AnalyseEvents(ExRootTreeReader *treeReader, MyPlots *plots) {
  TClonesArray *branchJet = treeReader->UseBranch("Jet");
  TClonesArray *branchElectron = treeReader->UseBranch("Electron");
  TClonesArray *branchMuon = treeReader->UseBranch("Muon");

  Long64_t allEntries = treeReader->GetEntries();

  cout << "** Chain contains " << allEntries << " events" << endl;

  Jet *jet[2];
  MissingET *met;
  Electron *electron;
  Muon *muon;

  Long64_t entry;
  Int_t i;

  // Loop over all events
  for (entry = 0; entry < allEntries; ++entry) {
    // Load selected branches with data from specified event
    treeReader->ReadEntry(entry);

    // Event selection
    int nSignalLeptons = 0;
    int nBaselineLeptons = 0;
    for (i = 0; i < branchElectron->GetEntriesFast(); ++i) {
      electron = (Electron*) branchElectron->At(i);
      if (electron->PT > 28.) ++nSignalLeptons;
      if (electron->PT > 10.) ++nBaselineLeptons;
    }

    for (i = 0; i < branchMuon->GetEntriesFast(); ++i) {
      muon = (Muon*) branchMuon->At(i);
      if (muon->PT > 28.) ++nSignalLeptons;
      if (muon->PT > 10.) ++nBaselineLeptons;
    }

    if (nSignalLeptons != 1 || nBaselineLeptons > 1) continue;

    // Analyse two leading jets
    if (branchJet->GetEntriesFast() >= 2) {
      jet[0] = (Jet*) branchJet->At(0);
      jet[1] = (Jet*) branchJet->At(1);

      plots->fJetPT[0]->Fill(jet[0]->PT);
      plots->fJetPT[1]->Fill(jet[1]->PT);

      plots->fJetM->Fill(jet[0]->Mass);

    }
  }
}

//------------------------------------------------------------------------------

void PrintHistograms(ExRootResult *result, MyPlots *plots) {
  result->Print("png");
}

//------------------------------------------------------------------------------

void bsm4tops(const char *inputFile) {
  gSystem->Load("libDelphes");
  gSystem->Load("libfastjet.so");
  gROOT->SetBatch();

  TChain *chain = new TChain("Delphes");
  chain->Add(inputFile);

  ExRootTreeReader *treeReader = new ExRootTreeReader(chain);
  ExRootResult *result = new ExRootResult();

  MyPlots *plots = new MyPlots;

  BookHistograms(result, plots);

  AnalyseEvents(treeReader, plots);

  PrintHistograms(result, plots);

  result->Write("results.root");

  cout << "** Exiting..." << endl;

  delete plots;
  delete result;
  delete treeReader;
  delete chain;
}
//------------------------------------------------------------------------------