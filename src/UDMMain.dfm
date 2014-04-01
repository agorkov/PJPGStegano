object DMMain: TDMMain
  OldCreateOrder = False
  Height = 150
  Width = 215
  object OPD1: TOpenPictureDialog
    Filter = 
      'All supported(*.jpg;*.jpeg)|*.jpg;*.jpeg|JPEG Image File (*.jpg)' +
      '|*.jpg|JPEG Image File (*.jpeg)|*.jpeg'
    Left = 8
    Top = 8
  end
  object OD1: TOpenDialog
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Left = 56
    Top = 8
  end
  object MainMenu1: TMainMenu
    Left = 32
    Top = 64
    object N1: TMenuItem
      Caption = #1060#1072#1081#1083
      object N2: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        OnClick = N2Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object N4: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = N4Click
      end
    end
    object N5: TMenuItem
      Caption = '?'
      object N6: TMenuItem
        Caption = #1054#1073' '#1072#1074#1090#1086#1088#1077
        OnClick = N6Click
      end
    end
  end
end
