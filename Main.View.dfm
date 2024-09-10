object MainView: TMainView
  Left = 0
  Top = 0
  Caption = 'Jar Builder'
  ClientHeight = 318
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -17
  Font.Name = 'Bahnschrift SemiLight SemiConde'
  Font.Style = []
  Font.Quality = fqClearTypeNatural
  OnCreate = FormCreate
  DesignSize = (
    624
    318)
  TextHeight = 21
  object Lbl_1: TLabel
    Left = 16
    Top = 8
    Width = 89
    Height = 21
    Caption = 'Java Files Dir'
  end
  object Lbl_2: TLabel
    Left = 16
    Top = 64
    Width = 137
    Height = 21
    Caption = '[ Androi.Jar Libs ] Dir'
  end
  object Memo_Log: TMemo
    Left = 8
    Top = 128
    Width = 601
    Height = 161
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = 2891284
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clLime
    Font.Height = -17
    Font.Name = 'Bahnschrift SemiLight SemiConde'
    Font.Style = []
    Font.Quality = fqClearTypeNatural
    Lines.Strings = (
      '')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 0
    ExplicitWidth = 599
    ExplicitHeight = 153
  end
  object Pnl_Status: TPanel
    Left = 0
    Top = 291
    Width = 624
    Height = 27
    Align = alBottom
    Alignment = taLeftJustify
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 283
    ExplicitWidth = 622
  end
  object Pnl_JarFilesDir: TPanel
    Left = 8
    Top = 32
    Width = 335
    Height = 29
    Caption = 'Pnl_JarFilesDir'
    TabOrder = 2
    object Edt_JarFilesDir: TEdit
      Left = 1
      Top = 1
      Width = 255
      Height = 27
      Align = alClient
      TabOrder = 0
      OnChange = Edt_JarFilesDirChange
      ExplicitHeight = 29
    end
    object Btn_LoadJarFilesDir: TButton
      Left = 256
      Top = 1
      Width = 78
      Height = 27
      Align = alRight
      Caption = 'Load Dir'
      TabOrder = 1
      OnClick = Btn_LoadJarFilesDirClick
    end
  end
  object Pnl_AndroidJarPath: TPanel
    Left = 8
    Top = 85
    Width = 335
    Height = 29
    Caption = 'Pnl_JarFilesDir'
    TabOrder = 3
    object Edt_AndroidJarPath: TEdit
      Left = 97
      Top = 1
      Width = 159
      Height = 27
      Align = alClient
      TabOrder = 0
      OnChange = Edt_JarFilesDirChange
      ExplicitHeight = 29
    end
    object Btn_LoadJarLibDir: TButton
      Left = 256
      Top = 1
      Width = 78
      Height = 27
      Align = alRight
      Caption = 'Load Dir'
      TabOrder = 1
      OnClick = Btn_LoadJarLibDirClick
    end
    object Btn_LoadJarFile: TButton
      Left = 1
      Top = 1
      Width = 96
      Height = 27
      Align = alLeft
      Caption = 'Load JarFile'
      TabOrder = 2
      OnClick = Btn_LoadJarFileClick
    end
  end
  object Pnl_Process: TPanel
    Left = 364
    Top = 16
    Width = 257
    Height = 105
    Anchors = [akTop, akRight]
    BevelOuter = bvLowered
    TabOrder = 4
    ExplicitLeft = 362
    object Lbl_3: TLabel
      Left = 1
      Top = 52
      Width = 255
      Height = 23
      Align = alClient
      Caption = 'Result Jar Name:'
      ExplicitWidth = 112
      ExplicitHeight = 21
    end
    object Edt_ResultJarName: TEdit
      Left = 1
      Top = 75
      Width = 255
      Height = 29
      Align = alBottom
      TabOrder = 0
      Text = 'UssdLib'
      TextHint = 'without extenssion !!'
    end
    object Btn_Build: TButton
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 249
      Height = 45
      Cursor = crHandPoint
      Align = alTop
      Caption = 'Compile and Build'
      Enabled = False
      TabOrder = 1
      OnClick = Btn_BuildClick
    end
  end
end
