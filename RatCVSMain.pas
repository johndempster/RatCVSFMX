unit RatCVSMain;
{ ========================================================================
  Rat cardivascular system simulation
  (c) J. Dempster, University of Strathclyde
  V2.0 1/9/97 Windows version
  V2.0a 30/9/97 L-NOARG does not inhibit sodium nitroprusside vasodilation
  V2.1 15/10/97 Now uses Windows API temporary file allocation routine
                Effect of Ach on peripheral flow now increased
  V2.1a 30/10/97 Incorrect X axis scaling when a sub-set of channels printed
                 now fixed.
  V2.2 20/9/98 16/32 bit version
  V2.2a 28/9/98 Now creates .tmp files in Windows temporary directory
  V3.0 8/1/99 Better cvs model. Now shows LVP, VBP, cardiac contractility
  V3.0b 1/2/99
  V3.0c 2/2/99 ... Normal/Pithed controls now radio buttons instead of menus
  V3.1 12/4/99 ... Stimulation of all symp. outflow except adrenal added
                   Prazozin corrected to Prazosin, and EC50=0.1 mg/kg
                   doses now displayed as /kg
  V3.1a 26/7/99 ... Name changed to RatCVS
  V3.2 4/7/00   ... High doses of acetylcholine in the presence of atropine
                    now increase BP and HR
                    Propranol, Atropine & Losartan increased in potency.
  V3.2a 3/5/01  ... Should now work with Italian/Spanish language Windows
  V3.2.2 29/08/01 ... Optimisations turned off to fix reversed for.. loop bug
                      which caused crashes under Windows NT
  V3.2.3 17/10/01 ... Help files no longer get lost when .RAT file saved
  V3.2.4 22/9/01 .... Drugs concentrations can now be entered with
                      Italian language settings
  V3.2.5 18/11/02 ... Compiled under Delphi V7
  V3.2.6 9/5/03 ..... Decimalseparator now included in ExtractInt()
  V3.2.7 2/12/03 .... Floating point error when trace reaches end of display fixed
                      Delay before re-drawing when trace reaches fixex
  V3.2.8 18/10/04 ... Memory exception error when selecting unknowns fixed
                      (FindDrug function)
                      Display calibration bars now adjust correctly when
                      window maximised
  V3.2.9 11/07/05 ... Memory Exceptions when program stopped fixed
  V3.3.0 29/01/07 ... Effect of renal nerve stimulation increased by 50%
                      Captopril no longer activates bradykinin receptors (only blocks ACE)
                      So captopril no longer appears to inhibit alpha-adrenoceptor response
                      of phenylephrine by directly activating arterial vasodilation
  V3.3.1 9/02/12 ...  Compiled under Delphi XE2
                      Now uses HTML Help format
  V3.3.2 11/02/14 ..  Milrinone now increases heart rate (due to effect of PDE inhibition of pacemaker current)
                      Error in GetTrailingPressure fixed reducing repetitive fluctuations in traces
                      Time course of heart systolic contraction now gaussian function
  V3.3.4 22/07/18     Adrenaline Beta2AdR EC50 reduced and Alpha1AdR EC50 increased to produce
                      slight reduction in ABP at low concentrations and increase in ABP at high concentrations
  V3.3.5 19.06.19     Adrenaline Beta2AdR EC50 reduced and Alpha1AdR EC50 restored to previous values
                      to produce INCREAESE in ABP at 5-10 ug/kg to make it more consistent with effect of ADR observed in original pithed rat papers.
  V3.3.6 16.07.20     Chart display updated to use scopedisplay component. Vertical range can now be adjusted.
  3.3.37 30.07.20     Channel blockers and enzyme inhibitors now moved from agonisy to antagonisy list
                      Incorrect alpha-2 adrenoceptor agonist activity of phentolamine removed
  4.0.0  12.07.24     Rebuilt using FMX multiplatfom framework
  ======================================================================== }

interface

uses
  System.SysUtils, System.StrUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.Ani, FMX.TabControl,
  FMX.ListBox, FMX.EditBox, FMX.NumberBox,
  SESNumberBox, FMX.Objects, SESScopeDisplay, System.IOUtils, System.ANsiStrings,
  FMX.Menus, FMX.Platform, RatCVSModel, FMX.Layouts, System.Actions, FMX.ActnList ;

const
    MaxChannels = 5 ;
    MaxPoints = 1000000 ;
    MaxDisplayPoints = 6000 ;
    MaxMarkers = 500 ;
    NumBytesPerMarker = 40 ;
    FileHeaderSize = (MaxMarkers+10)*NumBytesPerMarker ;
    DataFileExtension = '.RCV' ;

    StimulusInterval = 2.0 ;

    None = -1. ;

type

  TMainFrm = class(TForm)
    DisplayGrp: TGroupBox;
    Z: TTabControl;
    ChartTab: TTabItem;
    ExperimentTab: TTabItem;
    PithedRatSetup: TImageControl;
    BitmapAnimation1: TBitmapAnimation;
    ControlsGrp: TGroupBox;
    TissueGrp: TGroupBox;
    bNewExperiment: TButton;
    StimulusGrp: TGroupBox;
    DrugsTab: TTabControl;
    AgonistTab: TTabItem;
    AntagonistTab: TTabItem;
    UnknownTab: TTabItem;
    bStimulateNerve: TButton;
    StyleBook1: TStyleBook;
    cbAgonist: TComboBox ;
    cbAgonistDose: TComboBox;
    Label1: TLabel;
    bAddAgonist: TButton;
    cbAntagonist: TComboBox;
    cbAntagonistDose: TComboBox;
    Label3: TLabel;
    bAddAntagonist: TButton;
    cbUnknown: TComboBox;
    Label5: TLabel;
    cbUnknownDose: TComboBox;
    bAddUnknown: TButton;
    scDisplay: TScopeDisplay;
    TDisplayPanel: TPanel;
    edTDisplay: TSESNumberBox;
    edStartTime: TSESNumberBox;
    sbDisplay: TScrollBar;
    bTDisplayDouble: TButton;
    bTDisplayHalf: TButton;
    lbTDisplay: TLabel;
    lbStartTime: TLabel;
    Timer: TTimer;
    bRecord: TButton;
    bStop: TButton;
    MenuBar1: TMenuBar;
    mnFile: TMenuItem;
    mnNewExperiment: TMenuItem;
    mnLoadExperiment: TMenuItem;
    mnSaveExperiment: TMenuItem;
    mnEdit: TMenuItem;
    mnHelp: TMenuItem;
    mnPrint: TMenuItem;
    mnCopyData: TMenuItem;
    mnCopyImage: TMenuItem;
    mnExit: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    mnWebHelp: TMenuItem;
    rbNormal: TRadioButton;
    rbPithed: TRadioButton;
    rbSympNerve: TRadioButton;
    rbSympNerveToHeart: TRadioButton;
    rbSympNerveToAdrenals: TRadioButton;
    rbRenalNerve: TRadioButton;
    rbVagusNerve: TRadioButton;
    procedure FormShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure bNewExperimentClick(Sender: TObject);
    procedure bStimulateNerveClick(Sender: TObject);
    procedure cbAntagonistChange(Sender: TObject);
    procedure cbUnknownChange(Sender: TObject);
    procedure bRecordClick(Sender: TObject);
    procedure bStopClick(Sender: TObject);
    procedure edTDisplayKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure bAddAgonistClick(Sender: TObject);
    procedure scDisplayMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure mnExitClick(Sender: TObject);
    procedure mnCopyDataClick(Sender: TObject);
    procedure mnCopyImageClick(Sender: TObject);
    procedure bAddAntagonistClick(Sender: TObject);
    procedure bAddUnknownClick(Sender: TObject);
    procedure mnNewExperimentClick(Sender: TObject);
    procedure mnLoadExperimentClick(Sender: TObject);
    procedure mnSaveExperimentClick(Sender: TObject);
    procedure mnContentsClick(Sender: TObject);
    procedure mnPrintClick(Sender: TObject);
    procedure bTDisplayHalfClick(Sender: TObject);
    procedure bTDisplayDoubleClick(Sender: TObject);
    procedure edStartTimeKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure sbDisplayChange(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure mnWebHelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure rbPithedChange(Sender: TObject);
    procedure rbNormalChange(Sender: TObject);
    procedure rbNormalClick(Sender: TObject);
    procedure rbPithedClick(Sender: TObject);
    procedure cbAgonistChange(Sender: TObject);

  private
    { Private declarations }
    ADC : Array[0..MaxPoints*NumChannels-1] of SmallInt ;
    NumPointsInBuf : Integer ;   // No. of data points in buffer
    StartPoint : Integer ;
    NumPointsDisplayed : Integer ;
    ChangeDisplayWindow : Boolean ;
    ClearExperiment : Boolean ;

    HorCursors : Array[0..MaxChannels-1] of Integer ;
    VertCursor : Integer ;

    MarkerList : TStringList ;   // Chart annotation list

    UnsavedData : Boolean ;  // Un-saved data flag
    HelpFilePath : string ;

    DeathReported : Boolean ;

    procedure NewExperiment ;
    procedure EraseExperimentQuery( ModalQuery : Boolean ) ;

    procedure AddChartAnnotations ;
    procedure UpdateDisplay ;
    procedure AddDrugMarker( ChartAnnotation : String ) ;
    procedure LoadFromFile( FileName : String ) ;
    procedure SaveToFile( FileName : String ) ;
    procedure StopSimulation ;
    procedure UpdateDisplayDuration ;

    procedure SetComboBoxFontSize(
              ComboBox : TComboBox ;           // Combo box
              FontSize : Integer ) ;           // Size of text


    procedure SetDoseList(
              cbDrug : TComboBox ;    // List of drugs (in)
              cbDose : TComboBox ) ;  // List of Doses (out)

  public
    { Public declarations }

    procedure AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                           Keyword : string ;    // Key
                           Value : single        // Value
                           ) ; Overload ;

    procedure AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                           Keyword : string ;    // Key
                           Value : Integer        // Value
                           ) ; Overload ;

    procedure AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                           Keyword : string ;    // Key
                           Value : NativeInt        // Value
                           ) ; Overload ;

    procedure AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                           Keyword : string ;    // Key
                           Value : String        // Value
                           ) ; Overload ;

    procedure AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                           Keyword : string ;    // Key
                           Value : Boolean        // Value
                           ) ; Overload ;

   function GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                         KeyWord : string ;   // Key
                         Value : single       // Value
                         ) : Single ; Overload ;        // Return value

   function GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                         KeyWord : string ;   // Key
                         Value : Integer       // Value
                         ) : Integer ; Overload ;        // Return value

   function GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                         KeyWord : string ;   // Key
                         Value : NativeInt       // Value
                         ) : NativeInt ; Overload ;        // Return value

   function GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                         KeyWord : string ;   // Key
                         Value : string       // Value
                         ) : string ; Overload ;        // Return value

   function GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                         KeyWord : string ;   // Key
                         Value : Boolean       // Value
                         ) : Boolean ; Overload ;        // Return value


  function ExtractFloat ( CBuf : string ; Default : Single ) : extended ;
  function ExtractInt ( CBuf : string ) : longint ;
  function CreateCalBarValue( TargetValue : Single ) : Single ;

  end;

var
  MainFrm: TMainFrm;


implementation

uses
{$IFDEF MSWINDOWS}
winapi.shellapi,winapi.windows,
{$ENDIF}
{$IFDEF POSIX}
Posix.Stdlib , Posix.Unistd,
{$ENDIF POSIX}
System.Math, FMX.DialogService , ModalBox;

{$R *.fmx}

const
    MaxADCValue = 2047 ;
    MinADCValue = -2048 ;
    NoiseStDev = 10 ;
    MaxDisplayForce = 20.0 ;



procedure TMainFrm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
// -------------------------------------------
// Check with user if program should be closed
// -------------------------------------------
begin
    if not UnSavedData then CanClose := True
    else
        begin
        ModalBoxFrm.Left := Self.Left + 10 ;
        ModalBoxFrm.Top := Self.Top + 10 ;
        ModalBoxFrm.Caption := 'Close Program' ;
        ModalBoxFrm.MessageText := 'Experiment not saved: Are you sure you want to close the program' ;
        if ModalBoxFrm.ShowModal = mrYes then CanClose := True
                                         else CanClose := False ;
        end;
end;


procedure TMainFrm.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
// ----------------------------
// Process key presses on form
// ----------------------------
begin
//
//   Left and right arrow keys used to move vertical cursor on display

     case key of
          VKLEFT : scDisplay.MoveActiveVerticalCursor(-1) ;
          VKRIGHT : scDisplay.MoveActiveVerticalCursor(1) ;
          end ;
end;


procedure TMainFrm.FormResize(Sender: TObject);
begin
    scDisplay.Repaint ;
end;

procedure TMainFrm.FormShow(Sender: TObject);
// ------------------------------------------------
// Initialise controls when form is first displayed
// ------------------------------------------------
var
    FileName : String ;
    HelpFileName,LocalHelpFilePath : string ;
    i,ch : Integer ;
begin

     // Find help file
     HelpFileName := 'ratcvs.chm' ;
     HelpFilePath := ExtractFilePath(ParamStr(0)) + HelpFileName ;
//     TPath.GetTempPath( 512, TempPath ) ;
     LocalHelpFilePath := TPath.GetTempPath + HelpFileName ;
 //    TFile.Copy( PCHar(Application.HelpFile),PCHar(LocalHelpFilePath),  false ) ;
//     if FileExists(LocalHelpFilePath) then Application.HelpFile := LocalHelpFilePath ;

     // Create annotation list
     MarkerList := TStringList.Create ;

     { Setuo chart display }
     scDisplay.MaxADCValue :=  MaxADCValue ;
     scDisplay.MinADCValue := MinADCValue ;
     scDisplay.DisplayGrid := True ;

     { Set channel information }

     { Chart recorder traces }

     { Setuo chart display }
     scDisplay.MaxADCValue := MaxADCValue ;
     scDisplay.MinADCValue := MinADCValue ;
     scDisplay.DisplayGrid := True ;

     scDisplay.MaxPoints := MaxDisplayPoints ;
     scDisplay.NumPoints := 0 ;
     scDisplay.NumChannels := NumChannels ;
     sbDisplay.Max := 0 ;

     scDisplay.TScale := 1/20.0 ;
     edTDisplay.Min := 1.0/scDisplay.TScale ;
     edTDisplay.Max := 1E5 ;
     edTDisplay.ValueScale := scDisplay.TScale ;
     edStartTime.ValueScale := scDisplay.TScale ;
     edTDisplay.Value := scDisplay.MaxPoints ;
     scDisplay.XMin := 0 ;
     scDisplay.XMax := scDisplay.MaxPoints -1 ;

     { Blood pressure }
     scDisplay.ChanName[ChABP] := Model.ChanNames[ChABP] ;
     scDisplay.ChanUnits[ChABP] := Model.ChanUnits[ChABP] ;
     scDisplay.ChanScale[ChABP] := 300.0 / MaxADCValue ;
     scDisplay.ChanZero[ChABP] := 0.0 ;
     scDisplay.ChanOffsets[ChABP] := chABP ;
     scDisplay.yMax[ChABP] := 200.0/scDisplay.ChanScale[ChABP] ;
     scDisplay.yMin[ChABP]:= 0.0 ;
     scDisplay.ChanVisible[ChABP] := True ;

     { Left ventricular pressure }
     scDisplay.ChanName[chLVP] := Model.ChanNames[chLVP] ;
     scDisplay.ChanUnits[chLVP] := Model.ChanUnits[chLVP] ;
     scDisplay.ChanScale[ChLVP] := 300.0 / MaxADCValue ;
     scDisplay.ChanZero[chLVP] := 0.0 ;
     scDisplay.ChanOffsets[chLVP] := chLVP ;
     scDisplay.yMax[chLVP] := 200.0/scDisplay.ChanScale[ChLVP] ;
     scDisplay.yMin[chLVP]:= 0.0 ;
     scDisplay.ChanVisible[chLVP] := False ; // Start with channel in visible

     { Venous Pressure }
     scDisplay.ChanName[chCVP] := Model.ChanNames[chCVP] ;
     scDisplay.ChanUnits[chCVP] := Model.ChanUnits[chCVP] ;
     scDisplay.ChanScale[ChCVP] := 50.0 / MaxADCValue ;
     scDisplay.ChanZero[chCVP] := 0.0 ;
     scDisplay.ChanOffsets[chCVP] := chCVP ;
     scDisplay.yMax[chCVP] := 20.0/scDisplay.ChanScale[ChCVP] ;
     scDisplay.yMin[chCVP]:= 0.0 ;
     scDisplay.ChanVisible[chCVP] := False ; // Start with channel in visible

     { Cardiac contractile force (dLVP/dt)/LVP }
     scDisplay.ChanName[chHCF] := Model.ChanNames[chHCF] ;
     scDisplay.ChanUnits[chHCF] :=Model.ChanUnits[chHCF] ;
     scDisplay.ChanZero[chHCF] := 0.0 ;
     scDisplay.ChanScale[ChHCF] := 20.0 / MaxADCValue ;
     scDisplay.ChanOffsets[chHCF] := chHCF ;
     scDisplay.yMax[chHCF] := 20.0/scDisplay.ChanScale[ChHCF] ;
     scDisplay.yMin[chHCF]:= 0.0 ;
     scDisplay.ChanVisible[chHCF] := False ; // Start with channel in visible

     { Heart rate }
     scDisplay.ChanName[chHR] := Model.ChanNames[chHR] ;
     scDisplay.ChanUnits[chHR] := Model.ChanUnits[chHR] ;
     scDisplay.ChanZero[chHR] := 0.0 ;
     scDisplay.ChanScale[ChHR] := 1600.0 / MaxADCValue ;
     scDisplay.ChanOffsets[chHR] := chHR ;
     scDisplay.yMax[chHR]  := 800.0/scDisplay.ChanScale[ChHR] ;
     scDisplay.yMin[chHR]:= -10.0 ;
     scDisplay.ChanVisible[chHR] := True ;

     scDisplay.xMin := 0 ;
     scDisplay.xMax := scDisplay.MaxPoints-1 ;
     scDisplay.xOffset := 0 ;
     scDisplay.TScale := 1/20.0 ;
     edTDisplay.Min := 1.0/scDisplay.TScale ;
     edTDisplay.Max := 1E5 ;
     edTDisplay.ValueScale := scDisplay.TScale ;
     edStartTime.ValueScale := scDisplay.TScale ;
     edTDisplay.Value := scDisplay.MaxPoints ;

     { Create a set of zero level cursors }
     scDisplay.ClearHorizontalCursors ;
     for ch := 0 to scDisplay.NumChannels-1 do
         begin
         HorCursors[ch] := scDisplay.AddHorizontalCursor( ch, TAlphaColors.Red, True, '' ) ;
         scDisplay.HorizontalCursors[ch] := 0 ;
         end;

     // Vertical readout cursor
     scDisplay.ClearVerticalCursors ;
     VertCursor := scDisplay.AddVerticalCursor(-1,TAlphaColors.Green, '?y') ;
     scDisplay.VerticalCursors[VertCursor] := scDisplay.MaxPoints div 2 ;

     // Initialise experiment
     NewExperiment ;

     // Load file named in parameter string

     FileName :=  '' ;
     for i := 1 to ParamCount do
         begin
         if i > 1 then FileName := FileName + ' ' ;
         FileName := FileName + ParamStr(i) ;
         end ;

     if ContainsText( ExtractFileExt(FileName),'.obs') then
        begin
        if FileExists(FileName) then LoadFromFile( FileName ) ;
        end ;

     Timer.Enabled := True ;
     Model.InitialMixing := 0 ;

     end;

procedure TMainFrm.SetComboBoxFontSize(
          ComboBox : TComboBox ;           // Combo box
          FontSize : Integer ) ;           // Size of text
// ----------------------------------------
// Set font size of items in combo box list
// ----------------------------------------
var
    i : Integer ;
begin
     for i := 0 to ComboBox.Items.Count -1 do
         begin
         ComboBox.ListBox.ListItems[i].TextSettings.Font.Size := FontSize ;
         ComboBox.ListBox.ListItems[i].StyledSettings := ComboBox.ListBox.ListItems[i].StyledSettings - [TStyledSetting.Size];
         end;
end;


procedure TMainFrm.NewExperiment ;
// ------------------------------------
// Start new experiment with new tissue
// ------------------------------------
var
    i : Integer ;
begin


    // Initialise model
    Model.InitialiseModel ;

     // Create list of agonists
     cbAgonist.Clear ;
     Model.GetListOfDrugs( cbAgonist, dtAgonist ) ;
     SetComboBoxFontSize( cbAgonist, 13 ) ;

     if cbAgonist.Items.Count > 0 then
        begin
        cbAgonist.ItemIndex := 0 ;
        // Set up stock soln. concentration list
        SetDoseList( cbAgonist, cbAgonistDose ) ;
        end ;

     // Create list of agonists
     Model.GetListOfDrugs( cbAntagonist, dtAntagonist ) ;
     SetComboBoxFontSize( cbAntagonist, 13 ) ;
     if cbAntagonist.Items.Count > 0 then
        begin
        cbAntagonist.ItemIndex := 0 ;
        SetDoseList( cbAntagonist, cbAntagonistDose ) ;
        end ;

     // Create list of unknown drugs
     Model.GetListOfDrugs( cbUnknown, dtUnknown ) ;
     SetComboBoxFontSize( cbUnknown, 13 ) ;
     if cbUnknown.Items.Count > 0 then
        begin
        cbUnknown.ItemIndex := 0 ;
        SetDoseList( cbUnknown, cbUnknownDose ) ;
        end ;

     { Clear buffer  }
     for i := 0 to MaxPoints-1 do ADC[i] := 0 ;
     StartPoint :=  0 ;
     scDisplay.SetDataBuf( @ADC[StartPoint] ) ;
     scDisplay.XOffset := -1 ;
     NumPointsDisplayed := 0 ;
     NumPointsInBuf := 0 ;
     DeathReported := False ;

     rbNormal.IsChecked := True ;
     rbSympNerve.IsChecked := True ;
     TissueGrp.Enabled := True ;

     // Clear chart annotation
     MarkerList.Clear ;

     bRecord.Enabled := True ;
     bStop.Enabled := False ;

     sbDisplay.Max := scDisplay.MaxPoints ;
     sbDisplay.Enabled := False ;
     sbDisplay.Value := 0 ;

     bAddAgonist.Enabled := False ;
     bAddAntagonist.Enabled := False ;

     StopSimulation ;

     UnSavedData := False ;
     ChangeDisplayWindow := True ;

     end ;


procedure TMainFrm.rbNormalChange(Sender: TObject);
// ------------------------------
// Normal (unpithed) rat selected
// ------------------------------
begin
     Model.NormalRat := rbNormal.IsChecked ;
     end ;


procedure TMainFrm.rbNormalClick(Sender: TObject);
begin
     AddDrugMarker('Normal') ;
end;

procedure TMainFrm.rbPithedChange(Sender: TObject);
// ------------------------------
// Pithed rat selected
// ------------------------------
begin
     Model.NormalRat := not rbPithed.IsChecked ;
end;


procedure TMainFrm.rbPithedClick(Sender: TObject);
begin
    AddDRugMarker('Pithed') ;
end;

procedure TMainFrm.Action1Execute(Sender: TObject);
var
    OK : Boolean ;
begin

     if not UnsavedData then NewExperiment
     else
        begin

        ModalBoxFrm.Left := Self.Left + 10 ;
        ModalBoxFrm.Top := Self.Top + 10 ;
        ModalBoxFrm.Caption := 'New Experiment' ;
        ModalBoxFrm.MessageText := 'Experiment not saved: Are you sure you want to erase it?' ;
        ModalBoxFrm.Show ;

        if ModalBoxFrm.ShowModal = mrYes then OK := True
                                         else OK := False ;
        if OK then NewExperiment ;
        end;


     Log.d('action1');
end;

procedure TMainFrm.AddChartAnnotations ;
// -------------------------------------
// Add drug annotations to chart display
// -------------------------------------
var
    i : Integer ;
    MarkerPosition : Integer ;
begin

     scDisplay.ClearMarkers ;
     for i := 0 to MarkerList.Count-1 do
         begin
         MarkerPosition := Integer(MarkerList.Objects[i]) - scDisplay.XOffset ;
         if (MarkerPosition > 0) and (MarkerPosition < scDisplay.MaxPoints) then
            begin
            scDisplay.AddMarker( MarkerPosition, MarkerList.Strings[i] ) ;
            end ;
         end ;
     end ;


procedure TMainFrm.edStartTimeKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
// ------------------------
// Start time - Key pressed
// ------------------------
begin
    if Key = 13 then
       begin
       sbDisplay.Value := Round(edStartTime.Value) ;
       UpdateDisplayDuration ;
       end;

    end;


procedure TMainFrm.edTDisplayKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
// ------------------------------
// Display duration - key pressed
// ------------------------------
begin
    if Key = 13 then
       begin
       UpdateDisplayDuration ;
       end;
    end;


procedure TMainFrm.UpdateDisplay ;
// -------------------
// Update chart display
// -------------------
const
    NumPointsToAdd = 2 ;
var
    StartPoints : Integer ;
    i,YMax : Integer ;
    RangeChange : Boolean ;
begin

    // Add latest pair of computed trace points to display buffer
    for i  := 0 to NumChannels*NumPointsToAdd -1 do
        begin
            begin
            ADC[NumPointsInBuf*NumChannels + i] := Round( Model.ChanValues[i]/scDisplay.ChanScale[i mod NumChannels] ) ;
            end;
        end;
    NumPointsInBuf := NumPointsInBuf + NumPointsToAdd ;
    NumPointsDisplayed := NumPointsDisplayed + NumPointsToAdd ;


    if (NumPointsDisplayed >= scDisplay.MaxPoints) then
       begin
       StartPoints := scDisplay.MaxPoints div 10 ;
       NumPointsDisplayed := StartPoints ;
       scDisplay.NumPoints := NumPointsDisplayed-1 ;
       sbDisplay.Max := sbDisplay.Max + scDisplay.MaxPoints ;
       edStartTime.Max := sbDisplay.Max ;
       sbDisplay.Value := NumPointsInBuf - StartPoints + 1 ;
       scDisplay.XOffset := Round(sbDisplay.Value) ;
       scDisplay.SetDataBuf( @ADC[Round(sbDisplay.Value)*scDisplay.NumChannels] ) ;
       edStartTime.Value := scDisplay.XOffset ;
       scDisplay.Repaint ;
       // Add annotations to chart
       AddChartAnnotations ;
       end
    else
       begin

       RangeChange := False ;
       for i  := 0 to NumChannels-1 do
           begin
           YMax := Round( Model.ChanValues[i]/scDisplay.ChanScale[i] ) ;
           if YMax > scDisplay.YMax[i] then
           begin
              scDisplay.YMax[i] := scDisplay.YMax[i]*1.5 ;
              RangeChange := True ;
              end;
           end;

       scDisplay.DisplayNewPoints( NumPointsInBuf - 1 - scDisplay.XOffset, not RangeChange ) ;

       end;

    //scDisplay.Invalidate ;

    end ;


procedure TMainFrm.UpdateDisplayDuration ;
// ------------------------------
// Update display window duration
// ------------------------------
begin
    scDisplay.MaxPoints :=  Round(edTDisplay.Value) ;
    scDisplay.XMax := scDisplay.MaxPoints -1 ;
    scDisplay.VerticalCursors[VertCursor] := scDisplay.MaxPoints div 2 ;
    scDisplay.XOffset := Round(edStartTime.Value) ;
    sbDisplay.Value := Round(edStartTime.Value) ;
    scDisplay.SetDataBuf( @ADC[Round(sbDisplay.Value)*scDisplay.NumChannels] ) ;

    // Add annotations to chart
    AddChartAnnotations ;

    scDisplay.Repaint ;
    end;


procedure TMainFrm.SetDoseList(
          cbDrug : TComboBox ;    // List of drugs (in)
          cbDose : TComboBox ) ;  // List of Doses (out)
// -----------------------------
// Create list of available doses
// -----------------------------
var
    iDrug,i : Integer ;
    Scale,Dose : Single ;
    Units : String ;
begin

   cbDose.Clear ;

   if cbDrug.Items.Count > 1 then
      begin
      cbDrug.ItemIndex := Max(cbDrug.ItemIndex,0) ;
      iDrug := Integer(cbDrug.Items.Objects[cbDrug.ItemIndex]) ;
      if Model.Drugs[iDrug].MaxDose <= 1.0 then
         begin
         Scale := 1000.0 ;
         Units := 'ug/kg' ;
         end
      else
         begin
         Scale := 1.0 ;
         Units := 'mg/kg' ;
         end ;

      Dose := Model.Drugs[iDrug].MinDose ;
      cbDose.Clear ;
      while Dose <= Model.Drugs[iDrug].MaxDose do
       begin
       if Dose <= Model.Drugs[iDrug].MaxDose then cbDose.Items.Add( format(' %.2f %s ',[Dose*Scale,Units]) ) ;
       if (2.0*Dose) <= Model.Drugs[iDrug].MaxDose then cbDose.Items.Add( format(' %.1f %s ',[2.0*Dose*Scale,Units]) ) ;
       if (5.0*Dose) <= Model.Drugs[iDrug].MaxDose then cbDose.Items.Add( format(' %.1f %s ',[5.0*Dose*Scale,Units]) ) ;
       Dose := Dose*10.0 ;
       end ;
     cbDose.ItemIndex := 0 ;

     // Add dose in ng/kg in objects field

     for i := 0 to cbDose.Items.Count-1 do
         begin
         Dose := ExtractFloat( cbDose.Items[i], 0.0 );
         if ContainsText(cbDose.Items[i],'ug/kg') then Scale := 1000.0
         else if ContainsText(cbDose.Items[i],'mg/kg') then Scale := 1E6
         else Scale := 1.0 ;
         cbDose.Items.Objects[i] := Tobject(Round(Dose*Scale)) ;
         end;
     end ;

     // Set font size
     cbDose.DropDownCount := cbDose.Items.Count ;
     for i := 0 to cbDose.Items.Count-1 do
         begin
         cbDose.ListBox.ListItems[i].TextSettings.Font.Size := 15 ;
         cbDose.ListBox.ListItems[i].StyledSettings := cbDose.ListBox.ListItems[i].StyledSettings - [TStyledSetting.Size];
         end ;

end ;


procedure TMainFrm.TimerTimer(Sender: TObject);
// ---------------------
// Timed event scheduler
// ---------------------
var
  ch : Integer ;
begin

     // Ensure that horizontal cursor remains at zero
     for ch := 0 to  scDisplay.NumChannels-1 do
         begin
         if scDisplay.HorizontalCursors[HorCursors[ch]] <> 0.0 then scDisplay.HorizontalCursors[HorCursors[ch]] := 0.0 ;
         end ;

     if ClearExperiment and ModalBoxFrm.OK then
        begin
        NewExperiment ;
        ClearExperiment := False ;
        end;

     if not bRecord.Enabled then
        begin

        // Do next simulalation time step

        Model.DoSimulationStep ;
        UpdateDisplay ;

        { The rat dies if the B.P. falls too low for too long }
        if Model.Dead and (not DeathReported) then
        begin
        AddDrugMarker('Your rat has died!!!');
        DeathReported := True ;
        end ;
//        InitialMixing := InitialMixing + 1 ;
        end
     else
        begin
        // Display
        if ChangeDisplayWindow then
           begin
           scDisplay.XOffset := Round(sbDisplay.Value) ;
           edStartTime.Value := scDisplay.XOffset ;
           scDisplay.SetDataBuf( @ADC[Round(sbDisplay.Value)*scDisplay.NumChannels] ) ;
           scDisplay.MaxPoints := Round(edTDisplay.Value);
           scDisplay.XMax := scDisplay.MaxPoints -1 ;
           scDisplay.NumPoints := Min( NumPointsInBuf-Round(sbDisplay.Value)-1,
                                       Round(sbDisplay.Max - sbDisplay.Value)) ;
           // Add annotations to chart
           AddChartAnnotations ;
           ChangeDisplayWindow := False ;
           scDisplay.Repaint ;
           end ;
        end ;


end;


procedure TMainFrm.AddDrugMarker(
          ChartAnnotation : String
          ) ;
// ------------------------------
// Add drug addition/wash marker
// ------------------------------
begin
     if MarkerList.Count < MaxMarkers then begin
        ChartAnnotation := ReplaceStr( ChartAnnotation, '-00', '-' ) ;
        ChartAnnotation := ReplaceStr( ChartAnnotation, '00E', '0E' ) ;
        MarkerList.AddObject( ChartAnnotation, TObject(NumPointsInBuf) ) ;
        scDisplay.AddMarker( NumPointsInBuf - scDisplay.XOffset, ChartAnnotation ) ;
        end ;
     end ;


procedure TMainFrm.bAddAgonistClick(Sender: TObject);
// ----------------------------
// Add selected dose of agonist
// ----------------------------
var
    iDrug : Integer ;
    Dose,Scale : Single ;
    ChartAnnotation,Units : string ;
begin

    iDrug := Integer(cbAgonist.Items.Objects[cbAgonist.ItemIndex]);
    Dose := 1E-6*Integer(cbAgonistDose.Items.Objects[cbAgonistDose.ItemIndex]);

    Model.Drugs[iDrug].DoseInjected := Dose*Model.AddNoise(0.1) ;

    if Dose < 1.0 then
       begin
       Units := 'ug/kg';
       Scale := 1000.0 ;
       end
    else
       begin
       Units := 'mg/kg';
       Scale := 1.0 ;
       end ;

    // Add chart annotation
    ChartAnnotation := format('%s %.3g %s',
                       [Model.Drugs[iDrug].ShortName,Dose*Scale,Units] ) ;
     AddDrugMarker( ChartAnnotation ) ;

     end;


procedure TMainFrm.bAddAntagonistClick(Sender: TObject);
// -------------------------------
// Add selected dose of Antagonist
// -------------------------------
var
    iDrug : Integer ;
    Dose,Scale : Single ;
    ChartAnnotation,Units : string ;
begin

    iDrug := Integer(cbAntagonist.Items.Objects[cbAntagonist.ItemIndex]);
    Dose := 1E-6*Integer(cbAntagonistDose.Items.Objects[cbAntagonistDose.ItemIndex]);

   Model.Drugs[iDrug].DoseInjected := Dose*Model.AddNoise(0.1) ;

    if Dose < 1.0 then
       begin
       Units := 'ug/kg';
       Scale := 1000.0 ;
       end
    else
       begin
       Units := 'mg/kg';
       Scale := 1.0 ;
       end ;

    // Add chart annotation
    ChartAnnotation := format('%s %.3g %s',
                       [Model.Drugs[iDrug].ShortName,Dose*Scale,Units] ) ;
     AddDrugMarker( ChartAnnotation ) ;

     end;


procedure TMainFrm.bAddUnknownClick(Sender: TObject);
// -------------------------------
// Add selected dose of unknownt
// -------------------------------
var
    iDrug : Integer ;
    Dose,Scale : Single ;
    ChartAnnotation,Units : string ;
begin

    iDrug := Integer(cbUnknown.Items.Objects[cbUnknown.ItemIndex]);
    Dose := 1E-6*Integer(cbUnknownDose.Items.Objects[cbUnknownDose.ItemIndex]);

   Model.Drugs[iDrug].DoseInjected := Dose*Model.AddNoise(0.1) ;

    if Dose < 1.0 then
       begin
       Units := 'ug/kg';
       Scale := 1000.0 ;
       end
    else
       begin
       Units := 'mg/kg';
       Scale := 1.0 ;
       end ;

    // Add chart annotation
    ChartAnnotation := format('%s %.3g %s',
                       [Model.Drugs[iDrug].ShortName,Dose*Scale,Units] ) ;
     AddDrugMarker( ChartAnnotation ) ;

     end;

procedure TMainFrm.bRecordClick(Sender: TObject);
// ----------------
// Start simulation
// ----------------
begin

     bRecord.Enabled := False ;
     bStop.Enabled := True ;
     sbDisplay.Enabled := False ;
     bAddAgonist.Enabled := True ;
     bAddAntagonist.Enabled := True ;
     bNewExperiment.Enabled := False ;
     bNewExperiment.Enabled := False ;

     UnSavedData := True ;

     NumPointsDisplayed := 0 ;
     sbDisplay.Value := NumPointsInBuf + 1 ;
     scDisplay.XOffset := Round(sbDisplay.Value) ;
     scDisplay.SetDataBuf( @ADC[Round(sbDisplay.Value)*scDisplay.NumChannels] ) ;
     sbDisplay.Max := sbDisplay.Max + scDisplay.MaxPoints ;
     scDisplay.NumPoints := 0 ;
     Model.NormalRat := rbNormal.IsChecked ;

     // Add annotations to chart
     AddChartAnnotations ;

     end;


procedure TMainFrm.bStimulateNerveClick(Sender: TObject);
// ---------------------------------
// Stimulate autonomic nerve pathway
// ---------------------------------
var
    ChartAnnotation : string ;
begin

   if rbSympNerve.IsChecked then
      begin
      // Sympathetic nerves (excluding adrenal) acting on beta1
      Model.Drugs[Model.iSympBloodVessels].DoseInjected := 4.0*Model.Drugs[Model.iSympBloodVessels].Beta1AdR.Potency
                                                            *( 0.5 + Model.Alpha2Adr ) ;
      ChartAnnotation := 'Symp.Nv.(exc. adrenals)';
      end
   else if rbSympNerveToHeart.IsChecked then
      begin
      // Sympathetic nerves to heart Beta1 and Alpha1 a
      Model.Drugs[Model.iSympHeart].DoseInjected := 5.0*Model.Drugs[Model.iSympHeart].Beta1AdR.Potency
                                                    *( 0.5 + Model.Alpha2Adr ) ;
      ChartAnnotation := 'Symp.Nv.(heart)';
      end
   else if rbSympNerveToAdrenals.IsChecked then
      begin
      // Sympathetic nerves to adrenals
      Model.Drugs[Model.iSympAdrenal].DoseInjected := 2.*Model.Drugs[Model.iSympAdrenal].Beta1AdR.Potency ;
      ChartAnnotation := 'Symp.Nv.(adrenals)';
      end
   else if rbRenalNerve.IsChecked then
      begin
      // Renal nerve
      Model.Drugs[Model.iRenalNerve].DoseInjected := 5.*Model.Drugs[Model.iRenalNerve].Angt1R.Potency ;
      ChartAnnotation := 'Renal Nv.';
      end
   else
      begin
      // Vagus nerve
      Model.Drugs[Model.iVagusNerve].DoseInjected := 100.0*Model.Drugs[Model.iVagusNerve].VagChR.Potency ;
      ChartAnnotation := 'Vagus Nv.';
      end;

   AddDrugMarker( ChartAnnotation ) ;

   end ;


procedure TMainFrm.bStopClick(Sender: TObject);
// -------------------
// Stop button clicked
// -------------------
begin
    StopSimulation ;
end ;


procedure TMainFrm.bTDisplayDoubleClick(Sender: TObject);
// --------------------------------------------
// Increase display time window duration by 25%
// --------------------------------------------
begin
    edTDisplay.Value := edTDisplay.Value*1.25 ;
    UpdateDisplayDuration ;
end;


procedure TMainFrm.bTDisplayHalfClick(Sender: TObject);
// ----------------------------------
// Reduce display time window by half
// -----------------------------------
begin
    edTDisplay.Value := edTDisplay.Value/1.25 ;
    UpdateDisplayDuration ;
end;


procedure TMainFrm.StopSimulation ;
// ----------------
// Stop simulation
// ----------------
begin
     bRecord.Enabled := True ;
     bStop.Enabled := False ;
     sbDisplay.Enabled := True ;
     bAddAgonist.Enabled := False ;
     bAddAntagonist.Enabled := False ;
     bNewExperiment.Enabled := True ;
//     TissueGrp.Enabled := True ;

     end;


procedure TMainFrm.bNewExperimentClick(Sender: TObject);
// ---------------------
// Select new experiment
// ---------------------
begin
     EraseExperimentQuery( false ) ;
     end;


procedure TMainFrm.EraseExperimentQuery( ModalQuery : Boolean ) ;
// -----------------------------------
// Query user to clear experiment data
// -----------------------------------
begin

     ClearExperiment := True ;
     if not UnSavedData then ModalBoxFrm.OK := True
     else
        begin
        ModalBoxFrm.Left := Self.Left + 10 ;
        ModalBoxFrm.Top := Self.Top + 10 ;
        ModalBoxFrm.Caption := 'New Experiment' ;
        ModalBoxFrm.MessageText := 'Experiment not saved: Are you sure you want to erase it?' ;
        if ModalQuery then ModalBoxFrm.ShowModal
                      else ModalBoxFrm.Show ;
        end ;

     Log.d('Eraseexperimentquery');

end;


procedure TMainFrm.cbAgonistChange(Sender: TObject);
// -------
// Agonist changed
// ---------------
begin
    // Set up stock soln. concentration list
    SetDoseList( cbAgonist, cbAgonistDose ) ;
    end;


procedure TMainFrm.cbAntagonistChange(Sender: TObject);
// ---------------------------
// Update antagonist dose list
// ---------------------------
begin
    SetDoseList( cbAntagonist, cbAntagonistDose ) ;
    end;


Procedure TMainFrm.cbUnknownChange(Sender: TObject);
// ---------------------------
// Update unknown dose list
// ---------------------------
begin
      SetDoseList( cbUnknown, cbUnknownDose ) ;
      end;



procedure TMainFrm.SaveToFile(
          FileName : String
          ) ;
// ----------------------------
// Save chart recording to file
// ----------------------------
var
   ANSIHeaderBuf : array[0..FileHeaderSize] of ansichar ;
   Header : TStringList ;
   i : Integer ;
   FileHandle : THandle ;
begin

     // Create file header Name=Value string list
     Header := TStringList.Create ;

     FileHandle := FileCreate( FileName ) ;
     if Integer(FileHandle) < 0 then Exit ;

     AddKeyValue( Header, 'NPOINTS', NumPointsInBuf ) ;
     AddKeyValue( Header, 'NORMALRAT', Model.NormalRat ) ;

     AddKeyValue( Header, 'NMARKERS', MarkerList.Count ) ;
     for i := 0 to MarkerList.Count-1 do
         begin
         AddKeyValue( Header, format('MKP%d',[i]), Integer(MarkerList.Objects[i])) ;
         AddKeyValue( Header, format('MKT%d',[i]), MarkerList[i] ) ;
         end ;

     // Get ANSIstring copy of header text adn write to file
//     AnsiHeader := AnsiString(Header.Text) ;
     for i := 0 to Length(Header.Text)-1 do
         begin
         AnsiHeaderBuf[i] := ANSIChar(Header.Text[i+1]);
         end;
     AnsiHeaderBuf[Length(Header.Text)] := #0 ;

//     pAnsiHeader :=  Addr(AnsiHeader[1]);
     FileSeek( FileHandle, 0, 0 ) ;
     FileWrite( FileHandle, AnsiHeaderBuf, Length(Header.Text)) ;

     // Write chart data
     FileSeek( FileHandle, FileHeaderSize, 0 ) ;
     FileWrite( FileHandle, ADC, NumPointsInBuf*NumChannels*2 ) ;

     // Close file
     FileClose( FileHandle ) ;

     // Free header
     Header.Free ;

     UnSavedData := False ;
     end ;


procedure TMainFrm.sbDisplayChange(Sender: TObject);
// ---------------------------
// Scroll bar sosition changed
// ---------------------------
begin
    ChangeDisplayWindow := True ;
end;


procedure TMainFrm.scDisplayMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
// -------------------------------
// Mouse released on chart display
// -------------------------------
var
    ch : Integer ;
begin

     // Ensure that lower limit of display kept less than -10% of max.
     for ch := 0 to scDisplay.NumChannels-1 do
         if scDisplay.YMin[ch] < (MinADCValue div 10) then
            begin
            scDisplay.YMin[ch] := MinADCValue div 10 ;
            end;

     scDisplay.Repaint ;

end;

procedure TMainFrm.LoadFromFile(
          FileName : String
          ) ;
// ----------------------------
// Load chart recording from file
// ----------------------------
var
   AnsiHeaderBuf : Array[0..FileHeaderSize] of ANSIChar ;
   AnsiHeader : ANSIString ;
   Header : TStringList ;
   i : Integer ;
   FileHandle : THandle ;
   NumMarkers : Integer ;
   MarkerPoint : Integer ;
   MarkerText : String ;
begin

     // Create file header Name=Value string list
     Header := TStringList.Create ;

     NumPointsInBuf := 0 ;

     FileHandle := FileOpen( FileName, fmOpenRead ) ;
     if NativeInt(FileHandle) < 0 then Exit ;

     // Read header
     FileSeek( FileHandle, 0, 0 ) ;
     FileRead(FileHandle, ANSIHeaderBuf, FileHeaderSize ) ;
     ANSIHeader := ANSIString( ANSIHeaderBuf ) ;
     Header.Text := String(ANSIHeader) ;

     // Get tissue type
     NewExperiment ;

     NumPointsInBuf := 0 ;
     NumPointsInBuf := GetKeyValue( Header, 'NPOINTS', NumPointsInBuf ) ;
     Model.NormalRat := GetKeyValue( Header, 'NORMALRAT', Model.NormalRat ) ;
     rbNormal.IsChecked := Model.NormalRat ;
     rbPithed.IsChecked := not Model.NormalRat ;

     NumMarkers := 0 ;
     NumMarkers := GetKeyValue( Header, 'NMARKERS', NumMarkers ) ;
     MarkerList.Clear ;
     MarkerPoint := 0 ;
     for i := 0 to NumMarkers-1 do
         begin
         MarkerPoint := GetKeyValue( Header, format('MKPOINT%d',[i]), MarkerPoint ) ;
         MarkerPoint := GetKeyValue( Header, format('MKP%d',[i]), MarkerPoint) ;
         MarkerText := GetKeyValue( Header, format('MKTEXT%d',[i]), MarkerText ) ;
         MarkerText := GetKeyValue( Header, format('MKT%d',[i]), MarkerText ) ;
         MarkerList.AddObject( MarkerText, TObject(MarkerPoint)) ;
         end ;

     if NumPointsInBuf > 0 then
        begin
        FileSeek( FileHandle, FileHeaderSize, 0 );
        FileRead( FileHandle, ADC, NumPointsInBuf*NumChannels*2 ) ;
        end ;

     // Close data file
     FileClose( FileHandle ) ;

     Header.Free ;

     UnsavedData := False ;
     scDisplay.XOffset := 0 ;
     sbDisplay.Value := 0 ;
     sbDisplay.Max := NumPointsInBuf ;

     ChangeDisplayWindow := True ;

     end ;


procedure TMainFrm.mnCopyDataClick(Sender: TObject);
// -----------------------------
// Copy data points to clipboard
// -----------------------------
begin
    scDisplay.CopyDataToClipBoard ;
    end;


procedure TMainFrm.mnCopyImageClick(Sender: TObject);
// -----------------------------
// Copy image to clipboard
// -----------------------------
var
  ch: Integer;
begin

    scDisplay.TCalBar := CreateCalBarValue(((scDisplay.XMax - scDisplay.XMin)*scDisplay.TScale)*0.1) ;
    for ch := 0 to scDisplay.NumChannels-1 do
        begin
        scDisplay.ChanCalBar[ch] := CreateCalBarValue(((scDisplay.YMax[ch] - scDisplay.YMin[ch])*scDisplay.ChanScale[ch])*0.1) ;
        end;
    scDisplay.CopyImageToClipBoard ;
    end;


procedure TMainFrm.mnExitClick(Sender: TObject);
// ------------
// Stop Program
// ------------
begin
     Close ;
     end;


procedure TMainFrm.mnContentsClick(Sender: TObject);
// -----------------------
//  Help/Contents menu item
//  -----------------------
begin

    {$IFDEF MSWINDOWS}
     ShellExecute(0,'open', 'c:\windows\hh.exe',PChar(HelpFilePath), nil, SW_SHOWNORMAL) ;
    {$ENDIF}

     end;


procedure TMainFrm.mnLoadExperimentClick(Sender: TObject);
// -------------------------
// Load experiment from file
// -------------------------
begin

     EraseExperimentQuery( true ) ;

     if ModalBoxFrm.OK then
        begin

//      OpenDialog.options := [ofPathMustExist] ;
        OpenDialog.FileName := '' ;

        OpenDialog.DefaultExt := DataFileExtension ;
   //OpenDialog.InitialDir := OpenDirectory ;
        OpenDialog.Filter := format( ' Rat CVS Expt. (*%s)|*%s',
                                [DataFileExtension,DataFileExtension]) ;
        OpenDialog.Title := 'Load Experiment ' ;

       // Open selected data file
        if OpenDialog.execute then LoadFromFile( OpenDialog.FileName ) ;

        ModalBoxFrm.OK := False ;
        ClearExperiment := False ;
        end;

   end;


procedure TMainFrm.mnNewExperimentClick(Sender: TObject);
// ---------------------
// Select new experiment
// ---------------------
begin
     EraseExperimentQuery( false ) ;
     end;


procedure TMainFrm.mnPrintClick(Sender: TObject);
// ---------------------
// Print displayed trace
// ---------------------
var
  ch : Integer ;
begin

    scDisplay.TCalBar := CreateCalBarValue(((scDisplay.XMax - scDisplay.XMin)*scDisplay.TScale)*0.1) ;
    for ch := 0 to scDisplay.NumChannels-1 do
        begin
        scDisplay.ChanCalBar[ch] := CreateCalBarValue(((scDisplay.YMax[ch] - scDisplay.YMin[ch])*scDisplay.ChanScale[ch])*0.1) ;
        end;

    scDisplay.Print ;

end;


procedure TMainFrm.mnSaveExperimentClick(Sender: TObject);
// -----------------------
// Save experiment to file
// -----------------------
begin

     { Present user with standard Save File dialog box }
//     SaveDialog.options := [ofHideReadOnly,ofPathMustExist] ;
     SaveDialog.FileName := '' ;
     SaveDialog.DefaultExt := DataFileExtension ;
     SaveDialog.Filter := format( '  Rat CVS Expt. (*%s)|*%s',
                                  [DataFileExtension,DataFileExtension]) ;
     SaveDialog.Title := 'Save Experiment' ;

     if SaveDialog.Execute then SaveToFile( SaveDialog.FileName ) ;

     end ;


procedure TMainFrm.mnWebHelpClick(Sender: TObject);
//
// Web Help - Wiki from GitHub repository
// --------------------------------------
var
  URL: string;
begin
  URL := 'https://github.com/johndempster/RatCVSFMX/wiki';
{$IFDEF MSWINDOWS}
  URL := StringReplace(URL, '"', '%22', [rfReplaceAll]);
  ShellExecute(0, 'open', PChar(URL), nil, nil, SW_SHOWNORMAL);
  {$ENDIF}

  {$IFDEF MACOS}
      _system(PAnsiChar('open ' + AnsiString(URL)));
    {$ENDIF}
end;


procedure TMainFrm.AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                                KeyWord : string ;    // Key
                                Value : single        // Value
                                 ) ;
// ---------------------
// Add Key=Single Value to List
// ---------------------
begin
     List.Add( Keyword + format('=%.4g',[Value]) ) ;
end;


procedure TMainFrm.AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                                KeyWord : string ;    // Key
                                Value : Integer        // Value
                                 ) ;
// ---------------------
// Add Key=Integer Value to List
// ---------------------
begin
     List.Add( Keyword + format('=%d',[Value]) ) ;
end;

procedure TMainFrm.AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                                KeyWord : string ;    // Key
                                Value : NativeInt        // Value
                                 ) ;
// ---------------------
// Add Key=NativeInt Value to List
// ---------------------
begin
     List.Add( Keyword + format('=%d',[Value] )) ;
end;


procedure TMainFrm.AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                                KeyWord : string ;    // Key
                                Value : string        // Value
                                 ) ;
// ---------------------
// Add Key=string Value to List
// ---------------------
begin
     List.Add( Keyword + '=' + Value ) ;
end;


procedure TMainFrm.AddKeyValue( List : TStringList ;  // List for Key=Value pairs
                                KeyWord : string ;    // Key
                                Value : Boolean        // Value
                                 ) ;
// ---------------------
// Add Key=Boolean Value to List
// ---------------------
begin
     if Value = True then List.Add( Keyword + '=T' )
                     else List.Add( Keyword + '=F' )
end;


function TMainFrm.GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                               KeyWord : string ;   // Key
                               Value : single       // Value
                               ) : Single ;         // Return value
// ------------------------------
// Get Key=Single Value from List
// ------------------------------
var
    istart,idx : Integer ;
    s : string ;
begin

     idx := List.IndexOfName( Keyword ) ;
     if idx >= 0 then
        begin
        s := List[idx] ;
        // Find key=value separator and remove key
        istart := Pos( '=', s ) ;
        if istart > 0 then Delete( s, 1, istart ) ;
        Result := ExtractFloat( s, Value ) ;
        end
     else Result := Value ;

end;


function TMainFrm.GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                               KeyWord : string ;   // Key
                               Value : Integer       // Value
                               ) : Integer ;        // Return value
// ------------------------------
// Get Key=Integer Value from List
// ------------------------------
var
    istart,idx : Integer ;
    s : string ;
begin

     idx := List.IndexOfName( Keyword ) ;
     if idx >= 0 then
        begin
        s := List[idx] ;
        // Find key=value separator and remove key
        istart := Pos( '=', s ) ;
        if istart > 0 then Delete( s, 1, istart ) ;
        Result := STrToInt( s ) ;
        end
     else Result := Value ;

end;

function TMainFrm.GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                               KeyWord : string ;   // Key
                               Value : NativeInt       // Value
                               ) : NativeInt ;        // Return value
// ------------------------------
// Get Key=Integer Value from List
// ------------------------------
var
    istart,idx : Integer ;
    s : string ;
begin

     idx := List.IndexOfName( Keyword ) ;
     if idx >= 0 then
        begin
        s := List[idx] ;
        // Find key=value separator and remove key
        istart := Pos( '=', s ) ;
        if istart > 0 then Delete( s, 1, istart ) ;
        Result := STrToInt( s ) ;
        end
     else Result := Value ;

end;


function TMainFrm.GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                               KeyWord : string ;   // Key
                               Value : string       // Value
                               ) : string ;        // Return value
// ------------------------------
// Get Key=Integer Value from List
// ------------------------------
var
    istart,idx : Integer ;
    s : string ;
begin

      idx := List.IndexOfName( Keyword ) ;
     if idx >= 0 then
        begin
        s := List[idx] ;
        // Find key=value separator and remove key
        istart := Pos( '=', s ) ;
        if istart > 0 then Delete( s, 1, istart ) ;
        Result := s ;
        end
     else Result := Value ;

end;


function TMainFrm.GetKeyValue( List : TStringList ;  // List for Key=Value pairs
                               KeyWord : string ;   // Key
                               Value : Boolean       // Value
                               ) : Boolean ;        // Return value
// ------------------------------
// Get Key=Boolean Value from List
// ------------------------------
var
    istart,idx : Integer ;
    s : string ;
begin

      idx := List.IndexOfName( Keyword ) ;
     if idx >= 0 then
        begin
        s := List[idx] ;
        // Find key=value separator and remove key
        istart := Pos( '=', s ) ;
        if istart > 0 then Delete( s, 1, istart ) ;
        if ContainsText(s,'T') then Result := True
                               else Result := False ;
        end
     else Result := Value ;

end;


function TMainFrm.ExtractFloat ( CBuf : string ; Default : Single ) : extended ;
{ Extract a floating point number from a string which
  may contain additional non-numeric text }

var CNum : string ;
i : SmallInt ;

begin
     CNum := ' ' ;
     for i := 1 to length(CBuf) do begin
         if CharInSet( CBuf[i], ['0'..'9', 'E', 'e', '+', '-', '.', ',' ] ) then
            CNum := CNum + CBuf[i]
         else CNum := CNum + ' ' ;
         end ;

     { Correct for use of comma/period as decimal separator }
     if (formatsettings.DECIMALSEPARATOR = '.') and (Pos(',',CNum) <> 0) then
        CNum[Pos(',',CNum)] := formatsettings.DECIMALSEPARATOR ;
     if (formatsettings.DECIMALSEPARATOR = ',') and (Pos('.',CNum) <> 0) then
        CNum[Pos('.',CNum)] := formatsettings.DECIMALSEPARATOR ;

     try
        ExtractFloat := StrToFloat( CNum ) ;
     except
        on E : EConvertError do ExtractFloat := Default ;
        end ;
     end ;

function TMainFrm.ExtractInt ( CBuf : string ) : longint ;
{ Extract a 32 bit integer number from a string which
  may contain additional non-numeric text }
Type
    TState = (RemoveLeadingWhiteSpace, ReadNumber) ;
var
   CNum : string ;
   i : integer ;
   Quit : Boolean ;
   State : TState ;

begin
     CNum := '' ;
     i := 1;
     Quit := False ;
     State := RemoveLeadingWhiteSpace ;
     while not Quit do begin

           case State of

           { Ignore all non-numeric ansicharacters before number }
           RemoveLeadingWhiteSpace : begin
               if CharInSet( CBuf[i], ['0'..'9','E','e','+','-','.'] ) then State := ReadNumber
                                                            else i := i + 1 ;
               end ;

           { Copy number into string CNum }
           ReadNumber : begin
                { End copying when a non-numeric ansicharacter
                or the end of the string is encountered }
                if CharInSet( CBuf[i], ['0'..'9','E','e','+','-','.'] ) then begin
                   CNum := CNum + CBuf[i] ;
                   i := i + 1 ;
                   end
                else Quit := True ;
                end ;
           else end ;

           if i > Length(CBuf) then Quit := True ;
           end ;
     try
        ExtractInt := StrToInt( CNum ) ;
     except
        ExtractInt := 1 ;
        end ;
     end ;

function TMainFrm.CreateCalBarValue( TargetValue : Single ) : Single ;
// ---------------------------------------
// Generate single digit calibration value
// ---------------------------------------
var
    s : String ;
begin

    if TargetValue > 0.0 then
       begin
       s := format('%.0e',[TargetValue]) ;
       // Set fraction part to zero
       s[3] := '0' ;
       Result := ExtractFloat(s,TargetValue)
       end
    else
      begin
      Result := TargetValue ;
      end;
end;



end.
