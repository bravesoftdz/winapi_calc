///////////////////////////////////////////////////
//  WinApiCalc - ������ WinAPI ����������������. //
//  ����� - Dem@nXP                              //
//  E-mail: demanxp@mail.ru                      //
//  ICQ - 606986                                 //
//  ������� - HH-Team (http://hh-team.net.ru)    //
///////////////////////////////////////////////////
// ��������!!! ������ ��������� ���������������  //
// ���� ��� ������ WinAPI ����������������. ���  //
// ��������� ������ �� �������� � �� ����������- //
// ��������. ������, ������ API ���������������� //
// �� � ������� ������ �����. ������� ��������  //
// �� HH-Team ������ http://forum.hh-team.net.ru //
// ����� ����� � ������� �������� �����! :)      //
///////////////////////////////////////////////////


program WinApiCalc;
uses
  Windows, Messages;
  {���� ������ ��� ������ ������. ������, �� ����� ������
  ��������� �������, ��������, FloatToStr (SysUtil). ������
  ��� ��� ����� ������ ������ - ������. ����� ��������� ��
  ������� ������}

{$R *.RES}  //� ������� ����� ������� ������


const
  ClientWidth = 223; //������ ����� �����
  ClientHeight = 233; //������ ������� �����
  WndClass = 'TWinApiCalc';
  //��� ������ ���������� (��� ����� �������������� ��������)

  WndCaption = '����������� �� Win API'; //��������� �����

  Credits = 'WinAPI Calc by Dem@nXP'; //����� ����� ����� ����
  

  //������ ����� ���������, �������������� ����-����.

  // ������ �������� ��������� � 1, �.�. ���� ���������� ���
  // ���-�� ������������. ����� ��������� �� 100

  // ������. � ������ ������ ���� ��� ���������� ��������.
  BTN_0 = 100;
  BTN_1 = 101;
  BTN_2 = 102;
  BTN_3 = 103;
  BTN_4 = 104;
  BTN_5 = 105;
  BTN_6 = 106;
  BTN_7 = 107;
  BTN_8 = 108;
  BTN_9 = 109;
  BTN_RESULT = 110;      // =
  BTN_Plus = 111;        // +
  BTN_Minus = 112;       // -
  BTN_Add = 113;         // *
  BTN_Divide = 114;      // /
  BTN_RESET = 115;       // ��� ������ ����� ��� �������
  BTN_BACKSPACE = 116;   // Backspace
  BTN_SQRT = 117;        // ���������� ������
  BTN_1divx = 118;       // 1/�
  BTN_PlusMinus = 119;   // +/-
  BTN_Zap = 120;         // ������� (.)

  //Edit
  Ed_1 = 311;

  //Menu
  mFile = 600;  //����� � ��. ����
  mAbout = 700; //����� � ��. ����
  sBeep = 601; //����� Beep
  sExit = 602;  //�������� ���� File
  sAbout = 701; //�������� ���� About
  SEPARATOR = 161; //��������� (�������) � ��. ����

  id_Timer = 666; // ������������� �������

var
  Wc: TWndClassEx; //����� ����
  Wnd: HWND; //���������� ����� �����
  Msg: TMsg; //���������, ������� ����� "�������������"
  MainMenu: HMENU; //���� ������� ����
  SubMenuFile: HMENU; //����� File ��. ���� (�������)
  SubMenuAbout: HMENU; //����� About ��. ���� (�������)
  Buttons: array[0..20] of HWND; //����������� ������
  Font: HFONT; //�����. ����� �������, ��� ��������� ������ ������
  Edit1 ,Label1: HWND; //���������� ���� �����
  //����������, ������ ��� ����������
  x,y: extended;
  c: char; //������ ��������, ������� ����� �������
  i: integer; //������� (��� ������ � �������� ������������ ������)


Function GetText: string; //���������� ����� Edit'a
var
  count, //������ ������
   i: integer;
  buf : array [1..100] of char;  //�����
  s: string;  //��������� ����������, ��� ��������� ������
begin
  s:='';
  count:=GetWindowTextLength(Edit1); //����� ����� ������ Edit'a
  SendMessage(Edit1, WM_GetText, SizeOf(buf), integer(@buf));
  //� ������� SendMessage ���������� 4 ���������:
  //  1: ���������� ����
  //  2: ���������. � ����� ������ - WM_GetText (�������� �����)
  //  3: � ����� ������, ��� ������ ������, ���� ����� ������� �����
  //  4: ��������� �� �����. �.�. lParam ���������� integer, ��
  //  ����� ���� ����� �������� � ����������� ���� 

  For i:=1 to Count do
    s:=s+buf[i]; //����������� ���� ������ � ������
 
  //� ����� ���� ��������� ������� ����. ����� ������� ��������
  //������� � ���, ��� ����� ���� ����� ������ �������
  While (Length(s)>0) //���� ������ ������, �� �� �� ������
                      //����������� ������ ������
        and(s[1]='0') do //����� ������� ������� (������) ����
    If Length(s)>1 Then  //���� ����� ������ ������ ���� ����� ����
                         //�.�. �������� ���������� "0.*****"
      begin
        If s[2]<>'.' Then Delete(s,1,1) //�� ��������� ������ ������
                     Else Break; // ���� ������ ������ - �������,
                                 // ������� �� �����
      end
    else Delete(s,1,1); //���� ����� ��������, � ���� ������������
                        //- ������� ���, ����� ����� ������������
  GetText:=s; //s - ������������ ������, ��� � ���� ���������
end;

//�������� ���� ������ � ����� Edit'a. ������� ��� ��������
procedure EditAdd(c: char);
var
  s: string;
begin
  s:=GetText; //�������� ������������ �����
  If (s='') and (c='.') Then s:='0'; //���� ������ - �������,
                           //�� ����� ��� ������ ������ ����
  s:=s+c; //� ������������� ������ ��������� ������ ������
  SendMessage(Edit1, WM_SetText, Length(s), LParam(s));
  //�������� ������ ����� � Edit. 
end;

//��� �������� - �������� ����� Edit'a � ���� �����
Procedure Get(var x: extended);
var
  s: string;
  code: integer; //����������, ������  ��� ��������� val
begin
  s:=GetText; //�������� ����� Edit'a
  If s='' Then s:='0'; //���� �� ������, �� "��������" ���
  val(s,x,code); //��������� ������ � �����
  If code<>0 Then //���� code �� ����� ����, �� ��������� ������
     MessageBox( Wnd, '������� ������ �����������!', 'Error:', MB_OK or MB_ICONERROR);
end;

//��� �������� - ����� ����������-����� � Edit
Procedure WriteIm(x: extended);
var s: string;
begin
  Str(x:0:16,s); //��������� ����� � ������ � ��������� �� 16 ��������
  While s[Length(s)]='0' do Delete(s,Length(s),1); //������� �������� ����
  If s[Length(s)]='.' Then Delete(s,Length(s),1); //���� ����� �������� �����
                                    //��������� �������� ������� - ������� �
  SendMessage(Edit1, WM_SetText, Length(s), LParam(s)); //�������� ����� Edit'y
end;

//�������� ��������� ���������� :)
Procedure Calculate;
begin
  Get(y); //�������� �����, ����������� � Edit'e
  Case c of //�������, ����� �������� ����� ���������
  '+': x:=x+y; //���������
  '-': x:=x-y; // ������
  '*': x:=x*y; //  ��������
  '/': If y<>0 Then x:=x/y
    Else MessageBox(Wnd,'�� ���� ������ ������!','Error', MB_OK or MB_ICONERROR);
  end;
  WriteIm(x); //������� �����-��������� � Edit
  c:=' '; //�������� ��������
end;

//� ���� ��������� �� "�����" ������ ����� � ������ ��������
Procedure Process(ch: char);
var
  s: string;
begin
  c:=ch; //���������� ��������
  Get(x); //�������� ������ �����
  s:='0'; //�������� ����� Edit'a
  SendMessage(Edit1, WM_SetText, Length(s), LParam(s));
end;

//��������� �������� ���������� ������� � Edit'e
Procedure BACKSPACE;
var
  s: string;
begin
  s:=GetText; //�������� ����� EDit'a
  Delete(s,Length(s),1); //������� ��������� ������ :)
  If s='' Then s:='0'; //���� ������ ������, �� "��������" �
  SendMessage(Edit1, WM_SetText, Length(s), LParam(s)); //�������� ����� Edit'y
end;

//���������� ������ �� Edit'a � Edit
Procedure SQRTnow;
begin
  Get(x); //�������� ����� Edit'a ����� �����
  x:=Sqrt(x); //�������� ��. ������ ����� �����
  WriteIm(x); //������� ����� � Edit
end;

Procedure ChangeLabelFont;
var
  x: integer;
begin
   Randomize; //�������������� Random, ����� ��� ����� ���� ����� "����������"
   Font:=CreateFont( //������ ����� �� ���������� �����������
    -12,                           // Height
    Random(3)+4,                   // Width
    0,                             // Angle of Rotation
    0,                             // Orientation
    Random(1000),                  // Weight
    Random(2),                     // Italic
    Random(2),                     // Underline
    0,                             // Strike Out
    DEFAULT_CHARSET,               // Char Set
    OUT_DEFAULT_PRECIS,            // Precision
    CLIP_DEFAULT_PRECIS,           // Clipping
    DEFAULT_QUALITY,               // Render Quality
    DEFAULT_PITCH or FF_DONTCARE,  // Pitch & Family
    'Times New Roman');            // Font Name

   SendMessage( Label1, WM_SETFONT, Font, 0 ); //�������� �����
   InvalidateRect (Wnd, nil, False);
end;

//�������� ���������, �������������� ���������
function WindowProc( Wnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM ): LRESULT; stdcall;
begin
   //Msg - ���������� ���������
   case Msg of
      //���� �������� ����� ���������
      WM_DESTROY: begin
         PostQuitMessage( 0 );  //��������� �
         Result := 0; 
         Exit;  //��������� ��������� ������������ ���� ������ - �� �����������
      end;
      WM_TIMER: ChangeLabelFont; //�������� ����� �����
      WM_COMMAND: // WM_COMMAND ���������� ��� ������� ������ � ������� ����
         case LoWord( wParam ) of //������������ ��� ���������� ����� � wParam
            //������������ ������� ������� ����
            sExit: PostMessage( Wnd, WM_QUIT, 0, 0 );
            sAbout: MessageBox( Wnd, '����������� �� Win API -'+#10#13+
                                     'OpenSource ������ WinAPI'+#10#13+
                                     '���������������� ��'+#10#13+
                                     '      ..::  Dem@nXP  ::..'+#10#13+
                                     'E-Mail: demanxp@mail.ru'+#10#13+
                                     'ICQ: 606986'+#10#13+
                                     'Team: HH-Team'+#10#13+
                                     'Web: http://hh-team.net.ru'
                                       , 'About', 0 );
            sBeep: MessageBeep( MB_ICONWARNING ); //������ :) ��� ���� ��
                 // ��������� ������ - MB_ICONERROR. ������ ������ ������
                 // ����� ���������� � �������� ������� MessageBox
            //������������ ������� ������
            BTN_0: EditAdd('0'); //��������� ���� ������ ������
            BTN_1: EditAdd('1');
            BTN_2: EditAdd('2');
            BTN_3: EditAdd('3');
            BTN_4: EditAdd('4');
            BTN_5: EditAdd('5');
            BTN_6: EditAdd('6');
            BTN_7: EditAdd('7');
            BTN_8: EditAdd('8');
            BTN_9: EditAdd('9');
            BTN_ZAP: EditAdd('.');
            BTN_RESULT: Calculate; //��� ������� �� "=" ������ ����������
            BTN_Plus: Process('+'); //���������� ������ ����� � ��������(+)
            BTN_Minus: Process('-'); //���������� ������ ����� � ��������(-)
            BTN_ADD: Process('*'); //���������� ������ ����� � ��������(*)
            BTN_DIVIDE: Process('/'); //���������� ������ ����� � ��������(/)
            BTN_BACKSPACE: BACKSPACE; //������� ���� ������ � �����
            BTN_SQRT: SQRTnow; //�������� ��. ������
            BTN_1divx:
              begin
                //y ������ ��������� Calculate.
                x:=1; //E������
                c:='/'; //�����
                Calculate; //�� �
              end;
            BTN_PLUSMINUS:
              begin
                Get(x); //�������� �
                WriteIm(-x); //����������� ����
              end;
         end;
      else
         Result := DefWindowProc( Wnd, Msg, wParam, lParam );
      // DefWindowProc ������������ ��������� ��� ��������� ����,
      // ������� �� ������������ ���������� ���������.
   end;
end;


//�������, ��������� ������ ����
function CreateMenuItem( hMenu, SubMenu: HMENU; Cap: PChar;
                         _uID, _wID: UINT; Sep: boolean ): boolean;
// hMenu - ����, � ������� ����������� ����� �����
// SubMenu - ��������� � ���� ������� ������� (���� ��� ����)
// Cap - ��������� ������ ������
// _uID - ������ 0 (���� �������� ������������ � ������� InsertMenuItem)
// _wID - �������������, ��������� � ������ �������
// Sep - �������, �������� �� ����� ����� ������������ ��� ���
var
  Mi: MENUITEMINFO; //��� ��������� ����� ���������������� ��� �������� ����
begin
   with Mi do //��������� ���������
   begin
      cbSize := SizeOf( Mi );
      fMask := MIIM_STATE or MIIM_TYPE or MIIM_SUBMENU or MIIM_ID;
      if not Sep then //���� ��, ��� �� ������, �� �����������
         fType := MFT_STRING //�� ��� ������� ��������� ����� ����
      else
         fType := MFT_SEPARATOR; //����� - ��������� (�����������)
      fState := MFS_ENABLED;
      wID := _wID; //�������������
      hSubMenu := SubMenu; //������� (���� ��� ����)
      dwItemData := 0;
      dwTypeData := Cap; //��������� ������ ������ ����
      cch := SizeOf( Cap );
   end;
   Result := InsertMenuItem( hMenu, _uID, false, Mi ); //������ ����� ����
end;

BEGIN
   MainMenu := CreateMenu; //�������������� ������� ����
   // ��������� ��������� TWndClassEx
   with Wc do
   begin
      cbSize := SizeOf( Wc );
      style := CS_HREDRAW or CS_VREDRAW; //���� ������ ���������������� ���
                        //��������� ������������� ��� ��������������� �������
      lpfnWndProc := @WindowProc; //��������� �� ������� ���������
      cbClsExtra := 0; //���������� ������, ������������ ���������� �� ������ ����������.
      cbWndExtra := 0; //���������� ������, ������������ ���������� �� ������ ����������.
      hInstance := hInstance; //��������� ���������� ����������
      hIcon := LoadIcon(Wnd,'MAINICON'); //������ ����������
      hCursor := LoadCursor( 0, IDC_ARROW ); //������ ���������� (�������)
      hbrBackground := COLOR_BTNFACE+1; //���� ���� �����. ��������� ������ �����
                                   //���������� � �������� ������� GETSYSCOLOR
      lpszMenuName := @MainMenu; //��������� �� ������� ����
      lpszClassName := WndClass; //��� ������ ������������ �������
   end;
   RegisterClassEx( Wc ); // ������������ ����� � �������
   SubMenuFile := CreatePopupMenu; //������ ������� File
   SubMenuAbout := CreatePopupMenu; //������ ������� About
   //������ ����
  Wnd := CreateWindowEx ( 0, WndClass, WndCaption, WS_SYSMENU or WS_MINIMIZEBOX,
                          200, 200, ClientWidth, ClientHeight, 0, MainMenu, hInstance, nil);
  //�� ���� ������������ ��, ��� ��� ���� ��������. ��������� ��� ��� ������� ����� ��������
  //�� ��������� http://www.firststeps.ru/mfc/winapi/win/r.php?58

  // ������� ������ �������� ����
  CreateMenuItem( MainMenu, SubMenuFile, '����', 0, mFile, false );
  CreateMenuItem( MainMenu, SubMenuAbout, '������', 0, mAbout, false );

  // ������� ��� ������ File
  CreateMenuItem( SubMenuFile, 0, '�������', 0, sBeep, false );
  CreateMenuItem( SubMenuFile, 0, '', 0, SEPARATOR, true );
  CreateMenuItem( SubMenuFile, 0, '�����', 0, sExit, false );

  // ������� ��� ������ About
  CreateMenuItem( SubMenuAbout, 0, '� ���������', 0, sAbout, false );

  // �������������� ����
   DrawMenuBar( Wnd );
   
  // ���������� ����
  ShowWindow( Wnd, SW_SHOWNORMAL );

  // ��� ����� ��������� ������ �������������! � ���� ������� ������ ������������
  // ��������� ����� �����. 

  // ������ ������
   Buttons[0] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '0',
                                 BS_DEFPUSHBUTTON or WS_VISIBLE or WS_CHILD,
                                 11, 131, 36, 29, Wnd, BTN_0, hInstance, nil );
   Buttons[1] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '1',
                                 BS_DEFPUSHBUTTON or WS_VISIBLE or WS_CHILD,
                                 11, 97, 36, 29, Wnd, BTN_1, hInstance, nil );
   Buttons[2] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '2',
                                 BS_DEFPUSHBUTTON or WS_VISIBLE or WS_CHILD,
                                 51, 97, 36, 29, Wnd, BTN_2, hInstance, nil );
   Buttons[3] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '3',
                                 BS_DEFPUSHBUTTON or WS_VISIBLE or WS_CHILD,
                                 91, 97, 36, 29, Wnd, BTN_3, hInstance, nil );
   Buttons[4] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '4',
                                 BS_DEFPUSHBUTTON or WS_VISIBLE or WS_CHILD,
                                 11, 65, 36, 29, Wnd, BTN_4, hInstance, nil );
   Buttons[5] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '5',
                                 BS_DEFPUSHBUTTON or WS_VISIBLE or WS_CHILD,
                                 51, 65, 36, 29, Wnd, BTN_5, hInstance, nil );
   Buttons[6] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '6',
                                 BS_DEFPUSHBUTTON or  WS_VISIBLE or WS_CHILD,
                                 91, 65, 36, 29, Wnd, BTN_6, hInstance, nil );
   Buttons[7] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '7',
                                 BS_DEFPUSHBUTTON or WS_VISIBLE or WS_CHILD,
                                 11, 33, 36, 29, Wnd, BTN_7, hInstance, nil );
   Buttons[8] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '8',
                                 BS_DEFPUSHBUTTON or WS_VISIBLE or WS_CHILD,
                                 51, 33, 36, 29, Wnd, BTN_8, hInstance, nil );
   Buttons[9] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '9',
                                 BS_DEFPUSHBUTTON or WS_VISIBLE or WS_CHILD,
                                 91, 33, 36, 29, Wnd, BTN_9, hInstance, nil );
   Buttons[10] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '=',
                                 BS_DEFPUSHBUTTON or WS_VISIBLE or WS_CHILD,
                                 170, 131, 36, 29, Wnd, BTN_RESULT, hInstance, nil );
   Buttons[11] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '+',
                                 WS_VISIBLE or WS_CHILD,
                                 131, 131, 36, 29, Wnd, BTN_PLUS, hInstance, nil );
   Buttons[12] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '-',
                                 WS_VISIBLE or WS_CHILD,
                                 131, 98, 36, 29, Wnd, BTN_MINUS, hInstance, nil );
   Buttons[13] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '*',
                                 WS_VISIBLE or WS_CHILD,
                                 131, 66, 36, 29, Wnd, BTN_ADD, hInstance, nil );
   Buttons[14] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '/',
                                 WS_VISIBLE or WS_CHILD,
                                 131, 33, 36, 29, Wnd, BTN_DIVIDE, hInstance, nil );
   //Reset is not need :)
   Buttons[16] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', 'BkSp',
                                 WS_VISIBLE or WS_CHILD,
                                 170, 33, 36, 29, Wnd, BTN_BACKSPACE, hInstance, nil );
   Buttons[17] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', 'sqrt',
                                 WS_VISIBLE or WS_CHILD,
                                 170, 66, 36, 29, Wnd, BTN_SQRT, hInstance, nil );
   Buttons[18] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '1/x',
                                 WS_VISIBLE or WS_CHILD,
                                 170, 98, 36, 29, Wnd, BTN_1divx, hInstance, nil );
   Buttons[19] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', '+/-',
                                 WS_VISIBLE or WS_CHILD,
                                 51, 131, 36, 29, Wnd, BTN_PLUSMINUS, hInstance, nil );
   Buttons[20] := CreateWindowEx( WS_EX_STATICEDGE, 'Button', ',',
                                 WS_VISIBLE or WS_CHILD,
                                 91, 131, 36, 29, Wnd, BTN_ZAP, hInstance, nil );
   //�������� ������ ����� ���� ������� ������� ����� - ������. �� ��� ��� ������
   //��� ���������������� ������� ;) � ���� ������ ��������� ������ ����� �����������
   //��� ����� (�������� �����). � ����������/������ ������� � �������/�� .

   //�������� ���� �����
    Label1:= CreateWindow('Static', Credits, WS_VISIBLE or WS_CHILD or SS_LEFT,
    20, 163, ClientWidth, 20, Wnd, 0, hInstance, nil);

   // ������ ���� ����� (Edit)
   Edit1 := CreateWindowEx( WS_EX_STATICEDGE, 'Edit', '0',
                                  WS_VISIBLE or WS_CHILD,
                                 11, 3, 195, 20, Wnd, Ed_1, hInstance, nil );
   //�������� Edit'a � Label'a �� ������ ���������� �� �������� ������
   //��� ��������� ������ ��������� ����� �������� �� ���������
   // http://www.firststeps.ru/mfc/winapi/win/r.php?58

   //�������� ����� ���� ������, ����� ������ � �������
   Font := GetStockObject( ANSI_VAR_FONT  ); //�� ����� ����� ������
   For i:=10 to 20 do
     SendMessage( Buttons[i], WM_SETFONT, Font, 0 ); //�������� �����

   //�������� ����� ������� Label'a
   SendMessage(Wnd, WM_TIMER,0, 0); //��� ����� � ��� �������� ������

   SetTimer (Wnd, id_Timer, 1000, nil); //������ ������

  // ���� ��������� ���������
  while GetMessage( Msg, 0, 0, 0 ) do
  begin
    TranslateMessage( Msg );
    DispatchMessage( Msg );
  end;
  Halt( Msg.wParam );
END.
