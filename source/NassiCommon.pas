
const
  Wm_Nassi       = WM_User + 99;
  cProgClassName = 'TfrmNassi';       // muss mit Deklaration in u_Nassi.pas übereinstimmen


type
  tMessages = ( SendPanelHandle, GetPanelHandle, DoSetBounds );

{                       WPARAM             LPARAM
   SendPanelHandle:      Msg           NassiTabs.Handle
   GetPanelHandle :    FormHandle        PanelHandle
   DoSetBounds           Msg            Width / Height
}


