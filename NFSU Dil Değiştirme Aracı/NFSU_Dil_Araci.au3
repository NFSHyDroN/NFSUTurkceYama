; ============================================================
;  NFS Underground Dil Değiştirme Aracı
;  - Registry tabanlı dil değiştirme
;  - Gömülü logo
;  - Yönetici yetkisi
;  - Türkçe arayüz / İngilizce registry eşlemesi
; ============================================================

#RequireAdmin
#pragma compile(ExecLevel, requireAdministrator)
#pragma compile(Icon, "ikon.ico")
#pragma compile(FileDescription, "Güvenli kayıt defteri tabanlı dil değiştirme aracı")
#pragma compile(FileVersion, "1.0.0")
#pragma compile(ProductName, "NFS Underground Dil Değiştirme Aracı")
#pragma compile(ProductVersion, "1.0")
#pragma compile(LegalCopyright, "NFSHyDroN")
#pragma compile(CompanyName, "NFSHyDroN Araçları")

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ComboConstants.au3>
#include <StaticConstants.au3>
#include <MsgBoxConstants.au3>
#include <GDIPlus.au3>

; ============================================================
;  SABİTLER
; ============================================================

Global Const $g_sRegPathLanguage = "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\EA GAMES\Need For Speed Underground"
Global Const $g_sRegPathLanguageName = "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\EA GAMES\Need For Speed Underground\1.0"

; ComboBox içinde görünen Türkçe isimler
Global Const $g_sUiLanguageList = "İngilizce|Almanca|Fransızca|İtalyanca|İspanyolca|İsveççe|Hollandaca|Korece|Çince"

; Varsayılan değerler
Global Const $g_sDefaultUiLanguage = "İngilizce"
Global Const $g_sDefaultRegLanguage = "English US"

; EXE içine gömülü logo çalışma anında geçici klasöre açılır
Global Const $g_sLogoExtractedPath = @TempDir & "\NFSU_Dil_Araci_logo.png"

; ============================================================
;  DİL EŞLEME TABLOSU
;  [0] = UI'de görünen Türkçe isim
;  [1] = Registry'ye yazılacak oyun dili
; ============================================================

Global $g_aUiLanguages[9] = [ _
        "İngilizce", _
        "Almanca", _
        "Fransızca", _
        "İtalyanca", _
        "İspanyolca", _
        "İsveççe", _
        "Hollandaca", _
        "Korece", _
        "Çince" _
]

Global $g_aRegLanguages[9] = [ _
        "English US", _
        "German", _
        "French", _
        "Italian", _
        "Spanish", _
        "Swedish", _
        "Dutch", _
        "Korean", _
        "Chinese" _
]

; ============================================================
;  YARDIMCI FONKSİYONLAR
; ============================================================

; Registry'deki dili, arayüzde göstereceğimiz Türkçe isme çevirir
Func _GetUiLanguageFromRegistry($sRegLanguage)
    For $i = 0 To UBound($g_aRegLanguages) - 1
        If $g_aRegLanguages[$i] = $sRegLanguage Then
            Return $g_aUiLanguages[$i]
        EndIf
    Next
    Return $g_sDefaultUiLanguage
EndFunc

; Arayüzde seçilen Türkçe dili, registry'ye yazılacak oyun diline çevirir
Func _GetRegistryLanguageFromUi($sUiLanguage)
    For $i = 0 To UBound($g_aUiLanguages) - 1
        If $g_aUiLanguages[$i] = $sUiLanguage Then
            Return $g_aRegLanguages[$i]
        EndIf
    Next
    Return $g_sDefaultRegLanguage
EndFunc

; Hedef registry anahtarlarına dili yazar
Func _ApplyLanguageToRegistry($sRegLanguage)
    If Not RegWrite($g_sRegPathLanguage, "Language", "REG_SZ", $sRegLanguage) Then
        Return SetError(1, 0, False)
    EndIf

    If Not RegWrite($g_sRegPathLanguageName, "LanguageName", "REG_SZ", $sRegLanguage) Then
        Return SetError(2, 0, False)
    EndIf

    Return True
EndFunc

; GDI+ kaynaklarını güvenli şekilde kapatır
Func _CleanupResources()
    If IsDeclared("g_hImage") And $g_hImage <> 0 Then
        _GDIPlus_ImageDispose($g_hImage)
    EndIf

    If IsDeclared("g_hGraphics") And $g_hGraphics <> 0 Then
        _GDIPlus_GraphicsDispose($g_hGraphics)
    EndIf

    _GDIPlus_Shutdown()
EndFunc

; Aracın hakkında penceresine oluşturur
Func _ShowAboutWindow()
    Local $w = 300
    Local $h = 180

    Local $x = (@DesktopWidth - $w) / 2
    Local $y = (@DesktopHeight - $h) / 2

    Local $hAbout = GUICreate("Hakkında", $w, $h, $x, $y, -1, $WS_EX_TOPMOST)

    Local $version = "1.0.0"
    Local $developer = "NFSHyDroN"

    GUICtrlCreateLabel("NFS Underground Dil Değiştirme Aracı", 20, 20, 280, 20)

	Local $idLblVersion = GUICtrlCreateLabel("Sürüm: ", 19, 50, 200, 20)
	GUICtrlSetFont($idLblVersion, 9, 700)
	GUICtrlCreateLabel($version, 65, 51, 200, 20)

	Local $idLblDeveloper = GUICtrlCreateLabel("Geliştirici: ", 20, 70, 200, 20)
	GUICtrlSetFont($idLblDeveloper, 9, 700)
	GUICtrlCreateLabel($developer, 80, 71, 200, 20)

    GUICtrlCreateLabel("Kayıt Defteri tabanlı dil değiştirme aracı", 20, 100, 280, 20)

    Local $btnClose = GUICtrlCreateButton("Kapat", 120, 130, 80, 25)

    GUISetState(@SW_SHOW, $hAbout)

    While 1
        Local $m = GUIGetMsg()

        Switch $m
            Case $btnClose, $GUI_EVENT_CLOSE
                GUIDelete($hAbout)
                Return
        EndSwitch
    WEnd
EndFunc

; ============================================================
;  LOGO DOSYASINI EXE'DEN GEÇİCİ KLASÖRE AÇ
; ============================================================

If Not FileInstall("logo.png", $g_sLogoExtractedPath, 1) Then
    MsgBox($MB_ICONERROR, "Hata", "Gömülü logo dosyası açılamadı.")
    Exit
EndIf

; Program kapanırken temizlik yapılsın
OnAutoItExitRegister("_CleanupResources")

; ============================================================
;  GDI+ BAŞLAT
; ============================================================

_GDIPlus_Startup()

; ============================================================
;  PENCERE OLUŞTUR
; ============================================================

Global Const $g_iWidth = 425
Global Const $g_iHeight = 330

Global $g_iX = (@DesktopWidth - $g_iWidth) / 2
Global $g_iY = (@DesktopHeight - $g_iHeight) / 2

Global $g_hGUI = GUICreate("NFS Underground Dil Değiştirme Aracı", $g_iWidth, $g_iHeight, $g_iX, $g_iY)
GUISetBkColor(0xF6F7FB, $g_hGUI)

; GUI oluşturulduktan sonra logo resmi yüklenir
Global $g_hGraphics = _GDIPlus_GraphicsCreateFromHWND($g_hGUI)
Global $g_hImage = _GDIPlus_ImageLoadFromFile($g_sLogoExtractedPath)

; ============================================================
;  MEVCUT DİLİ OKU VE TÜRKÇEYE ÇEVİR
; ============================================================

Global $g_sCurrentRegLanguage = RegRead($g_sRegPathLanguage, "Language")
If @error Or $g_sCurrentRegLanguage = "" Then $g_sCurrentRegLanguage = $g_sDefaultRegLanguage

Global $g_sCurrentUiLanguage = _GetUiLanguageFromRegistry($g_sCurrentRegLanguage)

; ============================================================
;  ARAYÜZ KONTROLLERİ
; ============================================================

; Logo
; (GDI+ ile çizim yapıldığı için klasik Pic kontrolü kullanılmıyor.)
; Logonun ekrana düzgün oturması için çizim konumu sabit tutuluyor.
; Gerekirse bu değerler sonradan değiştirilebilir.
; ------------------------------------------------------------

; Hakkında butonu
Global $g_idBtnAbout = GUICtrlCreateButton("Hakkında", 335, 10, 80, 25)

; Başlık / mevcut dil
Global $g_idLblCurrent = GUICtrlCreateLabel("Mevcut Dil: " & $g_sCurrentUiLanguage, 0, 145, 425, 20, $SS_CENTER)
GUICtrlSetFont($g_idLblCurrent, 10, 600)

; Yeni dil etiketi
Global $g_idLblLanguage = GUICtrlCreateLabel("Yeni Dil:", 0, 180, 425, 20, $SS_CENTER)
GUICtrlSetFont($g_idLblLanguage, 9, 400)

; ComboBox
Global $g_idCombo = GUICtrlCreateCombo("", 70, 205, 280, 25, $CBS_DROPDOWNLIST)
GUICtrlSetData($g_idCombo, $g_sUiLanguageList, $g_sCurrentUiLanguage)

; Eğer registry'den okunan değer listede yoksa varsayılanı seç
If GUICtrlRead($g_idCombo) = "" Then
    GUICtrlSetData($g_idCombo, $g_sUiLanguageList, $g_sDefaultUiLanguage)
EndIf

; Uygula butonu
Global $g_idBtnApply = GUICtrlCreateButton("Uygula", 160, 250, 100, 30)

GUISetState(@SW_SHOW, $g_hGUI)

; Logo bir kez çizilir
_GDIPlus_GraphicsDrawImage($g_hGraphics, $g_hImage, 85, 10)

; ============================================================
;  ANA DÖNGÜ
; ============================================================

While 1
    Local $msg = GUIGetMsg()

    Switch $msg
        Case $GUI_EVENT_CLOSE
            Exit

		Case $g_idBtnAbout
			_ShowAboutWindow()

        Case $g_idBtnApply
            Local $sSelectedUiLanguage = GUICtrlRead($g_idCombo)

            If $sSelectedUiLanguage = "" Then
                MsgBox($MB_ICONWARNING, "Uyarı", "Lütfen bir dil seçin.")
                ContinueLoop
            EndIf

            Local $sSelectedRegLanguage = _GetRegistryLanguageFromUi($sSelectedUiLanguage)

            ; Seçili dil zaten aktifse gereksiz yazma yapma
            If $sSelectedUiLanguage = $g_sCurrentUiLanguage Then
                MsgBox($MB_ICONINFORMATION, "Bilgi", "Seçilen dil zaten aktif.")
                ContinueLoop
            EndIf

            If Not _ApplyLanguageToRegistry($sSelectedRegLanguage) Then
                MsgBox($MB_ICONERROR, "Hata", "Kayıt defteri güncellenemedi.")
                ContinueLoop
            EndIf

            ; Ekrandaki mevcut dil bilgisini Türkçe olarak güncelle
            $g_sCurrentUiLanguage = $sSelectedUiLanguage
            GUICtrlSetData($g_idLblCurrent, "Mevcut Dil: " & $g_sCurrentUiLanguage)

            MsgBox($MB_ICONINFORMATION, "Başarılı", _
                    "Dil '" & $g_sCurrentUiLanguage & "' olarak güncellendi.")
    EndSwitch
WEnd