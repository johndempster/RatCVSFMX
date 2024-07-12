program RatCVS;

uses
  System.StartUpCopy,
  FMX.Forms,
  RatCVSMain in 'RatCVSMain.pas' {MainFrm},
  RatCVSModel in 'RatCVSModel.pas' {Model: TDataModule},
  ModalBox in 'ModalBox.pas' {ModalBoxFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainFrm, MainFrm);
  Application.CreateForm(TModel, Model);
  Application.CreateForm(TModalBoxFrm, ModalBoxFrm);
  Application.Run;
end.
