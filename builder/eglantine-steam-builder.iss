; Eglantine Steam Remote Play Builder.
; It installs a local build helper and source patch. It does not contain Steamworks files.

#define BuilderName "Eglantine Steam Remote Play Builder"
#define BuilderVersion "1.1.0"

[Setup]
AppId={{E28530FA-3AE1-45A8-913D-C61E27F86937}
AppName={#BuilderName}
AppVersion={#BuilderVersion}
AppVerName={#BuilderName} {#BuilderVersion}
VersionInfoVersion=1.1.0.0
VersionInfoDescription={#BuilderName}
DefaultDirName={localappdata}\Eglantine Steam Remote Play Builder
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableWelcomePage=no
DisableReadyPage=no
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
UninstallDisplayName={#BuilderName}
WizardStyle=modern
ShowLanguageDialog=auto
SetupLogging=yes
Compression=lzma2/ultra64
SolidCompression=yes
OutputDir=output
OutputBaseFilename=Eglantine-Steam-Remote-Play-Builder

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Messages]
english.WelcomeLabel2=This wizard makes a new, private Eglantine Windows build with Steam Remote Play Together.%n%nIt does not change an Eglantine folder you already use. Instead it downloads a source version or GitHub fork you choose, applies the Steam patch, and builds a separate output folder.%n%nYou need your own Visual Studio, Qt, Vulkan SDK, Steamworks SDK, and an App ID you are authorized to use for Remote Play Together. The wizard checks the local tools and folders before the build starts.%n%nOnly build a repository you trust: building source code runs that repository's build instructions on your PC.
french.WelcomeLabel2=Cet assistant crée une nouvelle version Windows privée d'Eglantine avec Steam Remote Play Together.%n%nIl ne modifie pas votre dossier Eglantine existant. Il télécharge à la place la version du code source ou le fork GitHub de votre choix, applique le patch Steam, et crée un dossier de sortie séparé.%n%nVous avez besoin de votre propre Visual Studio, Qt, SDK Vulkan, SDK Steamworks et d'un App ID que vous êtes autorisé à utiliser pour Remote Play Together. L'assistant vérifie les outils et dossiers locaux avant de démarrer la compilation.%n%nN'utilisez qu'un dépôt auquel vous faites confiance : compiler son code peut exécuter ses instructions de compilation sur votre PC.
english.FinishedHeadingLabel=The builder is ready
french.FinishedHeadingLabel=L'outil de compilation est prêt
english.FinishedLabelNoIcons=The build runs in a separate PowerShell window. It can take a long time the first time.%n%nThat window shows the result, output folder, zip, log, and any action needed. The wizard itself only installed the builder; it has not claimed that the Eglantine build succeeded.%n%nUse only an App ID you own or are explicitly authorized to use.
french.FinishedLabelNoIcons=La compilation s'exécute dans une fenêtre PowerShell séparée. La première fois, elle peut prendre du temps.%n%nCette fenêtre affiche le résultat, le dossier de sortie, le zip, le journal, et les actions nécessaires. L'assistant a seulement installé l'outil : il ne prétend pas que la compilation Eglantine a réussi.%n%nUtilisez uniquement un App ID que vous possédez ou que vous êtes explicitement autorisé à utiliser.

[CustomMessages]
english.RepoCaption=Eglantine source
french.RepoCaption=Code source Eglantine
english.RepoDescription=Choose the public GitHub repository and its version
french.RepoDescription=Choisissez le dépôt GitHub public et sa version
english.RepoSubCaption=Use the official repository, or paste the HTTPS URL of an Eglantine fork. Then enter a branch or release tag.
french.RepoSubCaption=Utilisez le dépôt officiel, ou collez l'URL HTTPS d'un fork Eglantine. Entrez ensuite une branche ou un tag de version.
english.RepositoryUrl=GitHub repository URL:
french.RepositoryUrl=URL du dépôt GitHub :
english.GitRef=Branch or release tag:
french.GitRef=Branche ou tag de version :
english.PathsCaption=Build requirements
french.PathsCaption=Éléments nécessaires à la compilation
english.PathsDescription=Choose the SDKs and a private build workspace
french.PathsDescription=Choisissez les SDK et un espace de compilation privé
english.PathsSubCaption=Choose the folders that contain the required files. The workspace will receive source, build files, logs, and the final private output. Allow at least 15 GB free space.
french.PathsSubCaption=Choisissez les dossiers qui contiennent les fichiers nécessaires. L'espace de compilation recevra le code source, les fichiers de compilation, les journaux et le résultat privé. Prévoyez au moins 15 Go libres.
english.SteamworksSdk=Steamworks SDK folder (the folder named sdk):
french.SteamworksSdk=Dossier du SDK Steamworks (le dossier nommé sdk) :
english.QtDir=Qt MSVC 2022 64-bit folder (6.8.3 recommended):
french.QtDir=Dossier Qt MSVC 2022 64-bit (6.8.3 recommandé) :
english.VulkanSdk=Vulkan SDK folder:
french.VulkanSdk=Dossier du SDK Vulkan :
english.Workspace=Private build workspace folder:
french.Workspace=Dossier privé de compilation :
english.AppIdCaption=Steam App ID
french.AppIdCaption=App ID Steam
english.AppIdDescription=Enter an authorized Steam App ID for the build
french.AppIdDescription=Entrez un App ID Steam autorisé pour la compilation
english.AppIdSubCaption=Enter an App ID you own or whose owner explicitly authorized you to use. The application must be configured for Remote Play Together. This builder does not grant permission to use another game's App ID. You can change your authorized App ID later from Eglantine's Multiplayer menu.
french.AppIdSubCaption=Entrez un App ID que vous possédez ou que son propriétaire vous a explicitement autorisé à utiliser. L'application doit être configurée pour Remote Play Together. Cet outil ne donne pas le droit d'utiliser l'App ID d'un autre jeu. Vous pourrez changer votre App ID autorisé plus tard dans le menu Multijoueur d'Eglantine.
english.AppId=Default Steam App ID:
french.AppId=App ID Steam par défaut :
english.ConsentCaption=Build confirmation
french.ConsentCaption=Confirmation de compilation
english.ConsentDescription=Read this before starting
french.ConsentDescription=Lisez ceci avant de démarrer
english.ConsentSubCaption=The builder makes an isolated worktree and does not overwrite your existing emulator installation.
french.ConsentSubCaption=L'outil crée un dossier de travail isolé et ne remplace pas votre installation Eglantine existante.
english.ConsentTrust=I trust the GitHub repository above and understand that building it can run its build instructions on this PC.
french.ConsentTrust=Je fais confiance au dépôt GitHub ci-dessus et je comprends que sa compilation peut exécuter ses instructions sur ce PC.
english.ConsentSteamworks=I understand that the result contains Valve's steam_api64.dll from my own Steamworks SDK, and I must not share or publish the resulting build.
french.ConsentSteamworks=Je comprends que le résultat contient le fichier steam_api64.dll de Valve provenant de mon propre SDK Steamworks, et que je ne dois pas partager ni publier cette compilation.
english.ConsentAppId=I am authorized to use the App ID above, and it is configured for Remote Play Together.
french.ConsentAppId=Je suis autorisé à utiliser l'App ID ci-dessus, et il est configuré pour Remote Play Together.
english.StartBuild=Start the build in a PowerShell window when I click Finish.
french.StartBuild=Démarrer la compilation dans une fenêtre PowerShell lorsque je clique sur Terminer.
english.InvalidRepository=Use a public GitHub HTTPS repository URL, for example:%n%nhttps://github.com/owner/Eglantine.git
french.InvalidRepository=Utilisez l'URL HTTPS d'un dépôt GitHub public, par exemple :%n%nhttps://github.com/owner/Eglantine.git
english.InvalidRef=Enter a branch or tag using letters, numbers, dots, dashes, underscores, slashes, or @.%n%nExamples: nx2, v0.1.0-rc3, branch-smileytatsu-dev-experimental-merge-74dc0c7d
french.InvalidRef=Entrez une branche ou un tag avec des lettres, chiffres, points, tirets, tirets bas, barres obliques ou @.%n%nExemples : nx2, v0.1.0-rc3, branch-smileytatsu-dev-experimental-merge-74dc0c7d
english.InvalidAppId=Enter a positive Steam App ID number that you are authorized to use.
french.InvalidAppId=Entrez un numéro d'App ID Steam positif que vous êtes autorisé à utiliser.
english.MissingFolder=The folder does not exist:%n%n%1
french.MissingFolder=Le dossier n'existe pas :%n%n%1
english.MissingFile=This folder is not the expected %1:%n%n%2
french.MissingFile=Ce dossier n'est pas le %1 attendu :%n%n%2
english.RootWorkspace=Choose a folder inside a drive for the build workspace, not the root of the drive itself.
french.RootWorkspace=Choisissez un dossier à l'intérieur d'un disque pour l'espace de compilation, pas la racine du disque.
english.ConsentNeeded=Tick both acknowledgement boxes before continuing.
french.ConsentNeeded=Cochez les deux cases de confirmation avant de continuer.
english.BuilderLaunchFailed=The builder was installed, but Windows could not start its build window:%n%n%1%n%nOpen this folder and double-click Run-Build.cmd:%n%n%2
french.BuilderLaunchFailed=L'outil a été installé, mais Windows n'a pas pu démarrer la fenêtre de compilation :%n%n%1%n%nOuvrez ce dossier et double-cliquez sur Run-Build.cmd :%n%n%2
english.ReviewRepository=Repository:
french.ReviewRepository=Dépôt :
english.ReviewReference=Reference:
french.ReviewReference=Référence :
english.ReviewSteamworks=Steamworks SDK:
french.ReviewSteamworks=SDK Steamworks :
english.ReviewQt=Qt:
french.ReviewQt=Qt :
english.ReviewVulkan=Vulkan SDK:
french.ReviewVulkan=SDK Vulkan :
english.ReviewWorkspace=Build workspace:
french.ReviewWorkspace=Espace de compilation :
english.ReviewAppId=Default Steam App ID:
french.ReviewAppId=App ID Steam par défaut :
english.ReviewInstall=The builder will be installed in:
french.ReviewInstall=L'outil sera installé dans :
english.ReviewSafe=It will not replace an existing Eglantine folder.
french.ReviewSafe=Il ne remplacera pas un dossier Eglantine existant.
english.OpenReadme=Show the builder instructions
french.OpenReadme=Afficher les instructions de l'outil

[Files]
Source: "payload\Build-SteamRemotePlay.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "payload\Run-Build.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "payload\steam-remote-play-together.patch"; DestDir: "{app}"; Flags: ignoreversion
Source: "payload\README-en.txt"; DestDir: "{app}"; DestName: "README.txt"; Languages: english; Flags: ignoreversion
Source: "payload\README-fr.txt"; DestDir: "{app}"; DestName: "README.txt"; Languages: french; Flags: ignoreversion

[UninstallDelete]
Type: files; Name: "{app}\BuildConfig.json"

[Run]
Filename: "{app}\README.txt"; Description: "{cm:OpenReadme}"; Flags: postinstall shellexec skipifsilent unchecked nowait

[Code]
var
  RepoPage: TInputQueryWizardPage;
  PathsPage: TInputDirWizardPage;
  AppIdPage: TInputQueryWizardPage;
  ConsentPage: TInputOptionWizardPage;
  BuildStarted: Boolean;

function GetQtDefault(): String;
begin
  Result := 'C:\Qt\6.8.3\msvc2022_64';
end;

function IsGitHubRepositoryUrl(const Value: String): Boolean;
var
  Lower: String;
begin
  Lower := Lowercase(Trim(Value));
  Result := (Pos('https://github.com/', Lower) = 1) and
            (Pos('?', Lower) = 0) and (Pos('#', Lower) = 0) and
            (Pos(' ', Lower) = 0) and (Pos('\', Lower) = 0);
end;

function EndsWith(const Value, Suffix: String): Boolean;
begin
  Result := (Length(Value) >= Length(Suffix)) and
    (Copy(Value, Length(Value) - Length(Suffix) + 1, Length(Suffix)) = Suffix);
end;

function IsSafeRef(const Value: String): Boolean;
var
  I: Integer;
  C: Char;
begin
  Result := (Length(Value) > 0) and (Length(Value) <= 128);
  if not Result then
    Exit;
  for I := 1 to Length(Value) do
  begin
    C := Value[I];
    if not (((C >= 'A') and (C <= 'Z')) or ((C >= 'a') and (C <= 'z')) or
            ((C >= '0') and (C <= '9')) or (C = '.') or (C = '_') or
            (C = '-') or (C = '/') or (C = '@')) then
    begin
      Result := False;
      Exit;
    end;
  end;
  Result := (Value[1] <> '/') and (Value[Length(Value)] <> '/') and
            (Pos('..', Value) = 0) and (Pos('//', Value) = 0) and
            (Pos('@{', Value) = 0) and not EndsWith(Value, '.lock') and
            (Value[Length(Value)] <> '.');
end;

function IsPositiveNumber(const Value: String): Boolean;
var
  I: Integer;
  NonZero: Boolean;
begin
  Result := Length(Value) > 0;
  NonZero := False;
  for I := 1 to Length(Value) do
  begin
    if (Value[I] < '0') or (Value[I] > '9') then
    begin
      Result := False;
      Exit;
    end;
    if Value[I] <> '0' then
      NonZero := True;
  end;
  Result := Result and NonZero;
end;

function HasExpectedFile(const Folder, RelativePath, Description: String): Boolean;
var
  FileName: String;
begin
  FileName := AddBackslash(Folder) + RelativePath;
  Result := FileExists(FileName);
  if not Result then
    MsgBox(FmtMessage(CustomMessage('MissingFile'), [Description, FileName]), mbError, MB_OK);
end;

function CheckFolder(const Folder, Description: String): Boolean;
begin
  Result := DirExists(Folder);
  if not Result then
    MsgBox(FmtMessage(CustomMessage('MissingFolder'), [Folder]), mbError, MB_OK);
end;

function IsDriveRoot(const Folder: String): Boolean;
var
  Expanded: String;
begin
  Expanded := ExpandFileName(Folder);
  Result := ((Length(Expanded) = 3) and (Expanded[2] = ':') and
             ((Expanded[3] = #92) or (Expanded[3] = '/')));
end;

function JsonEscape(const Value: String): String;
var
  I: Integer;
  C: Char;
begin
  Result := '';
  for I := 1 to Length(Value) do
  begin
    C := Value[I];
    if C = '\' then
      Result := Result + '\\'
    else if C = '"' then
      Result := Result + '\"'
    else if C = #13 then
      Result := Result + '\r'
    else if C = #10 then
      Result := Result + '\n'
    else
      Result := Result + C;
  end;
end;

function SaveBuildConfig(const ConfigPath: String): Boolean;
var
  Lines: TArrayOfString;
begin
  SetArrayLength(Lines, 10);
  Lines[0] := '{';
  Lines[1] := '  "schemaVersion": 1,';
  Lines[2] := '  "RepositoryUrl": "' + JsonEscape(Trim(RepoPage.Values[0])) + '",';
  Lines[3] := '  "GitRef": "' + JsonEscape(Trim(RepoPage.Values[1])) + '",';
  Lines[4] := '  "SteamworksSdk": "' + JsonEscape(PathsPage.Values[0]) + '",';
  Lines[5] := '  "QtDir": "' + JsonEscape(PathsPage.Values[1]) + '",';
  Lines[6] := '  "VulkanSdk": "' + JsonEscape(PathsPage.Values[2]) + '",';
  Lines[7] := '  "Workspace": "' + JsonEscape(PathsPage.Values[3]) + '",';
  Lines[8] := '  "SteamAppId": "' + JsonEscape(Trim(AppIdPage.Values[0])) + '"';
  Lines[9] := '}';
  Result := SaveStringsToUTF8File(ConfigPath, Lines, False);
end;

procedure InitializeWizard;
var
  DefaultSdk, DefaultVulkan, DefaultWorkspace: String;
begin
  RepoPage := CreateInputQueryPage(wpWelcome,
    CustomMessage('RepoCaption'), CustomMessage('RepoDescription'), CustomMessage('RepoSubCaption'));
  RepoPage.Add(CustomMessage('RepositoryUrl'), False);
  RepoPage.Add(CustomMessage('GitRef'), False);
  RepoPage.Values[0] := GetPreviousData('RepositoryUrl', 'https://github.com/Eglantine-Community/Eglantine.git');
  RepoPage.Values[1] := GetPreviousData('GitRef', 'nx2');

  PathsPage := CreateInputDirPage(RepoPage.ID,
    CustomMessage('PathsCaption'), CustomMessage('PathsDescription'), CustomMessage('PathsSubCaption'),
    False, SetupMessage(msgNewFolderName));
  PathsPage.Add(CustomMessage('SteamworksSdk'));
  PathsPage.Add(CustomMessage('QtDir'));
  PathsPage.Add(CustomMessage('VulkanSdk'));
  PathsPage.Add(CustomMessage('Workspace'));
  DefaultSdk := ExpandConstant('{src}\sdk');
  if not DirExists(DefaultSdk) then
    DefaultSdk := 'C:\Steamworks\sdk';
  DefaultVulkan := GetEnv('VULKAN_SDK');
  if DefaultVulkan = '' then
    DefaultVulkan := 'C:\VulkanSDK';
  DefaultWorkspace := ExpandConstant('{userdocs}\Eglantine Steam Builds');
  PathsPage.Values[0] := GetPreviousData('SteamworksSdk', DefaultSdk);
  PathsPage.Values[1] := GetPreviousData('QtDir', GetQtDefault());
  PathsPage.Values[2] := GetPreviousData('VulkanSdk', DefaultVulkan);
  PathsPage.Values[3] := GetPreviousData('Workspace', DefaultWorkspace);

  AppIdPage := CreateInputQueryPage(PathsPage.ID,
    CustomMessage('AppIdCaption'), CustomMessage('AppIdDescription'), CustomMessage('AppIdSubCaption'));
  AppIdPage.Add(CustomMessage('AppId'), False);
  AppIdPage.Values[0] := GetPreviousData('SteamAppId', '');

  ConsentPage := CreateInputOptionPage(AppIdPage.ID,
    CustomMessage('ConsentCaption'), CustomMessage('ConsentDescription'), CustomMessage('ConsentSubCaption'),
    False, False);
  ConsentPage.Add(CustomMessage('ConsentTrust'));
  ConsentPage.Add(CustomMessage('ConsentSteamworks'));
  ConsentPage.Add(CustomMessage('ConsentAppId'));
  ConsentPage.Add(CustomMessage('StartBuild'));
  ConsentPage.Values[3] := True;
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
  SetPreviousData(PreviousDataKey, 'RepositoryUrl', Trim(RepoPage.Values[0]));
  SetPreviousData(PreviousDataKey, 'GitRef', Trim(RepoPage.Values[1]));
  SetPreviousData(PreviousDataKey, 'SteamworksSdk', PathsPage.Values[0]);
  SetPreviousData(PreviousDataKey, 'QtDir', PathsPage.Values[1]);
  SetPreviousData(PreviousDataKey, 'VulkanSdk', PathsPage.Values[2]);
  SetPreviousData(PreviousDataKey, 'Workspace', PathsPage.Values[3]);
  SetPreviousData(PreviousDataKey, 'SteamAppId', Trim(AppIdPage.Values[0]));
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  // Silent installation is only for deployment/testing of the builder itself. It never starts a
  // build and it has no answers for custom pages, so retain their defaults in BuildConfig.json.
  Result := WizardSilent and ((PageID = RepoPage.ID) or (PageID = PathsPage.ID) or
    (PageID = AppIdPage.ID) or (PageID = ConsentPage.ID));
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  SteamSdk, QtDir, VulkanSdk, Workspace: String;
begin
  Result := True;
  if CurPageID = RepoPage.ID then
  begin
    if not IsGitHubRepositoryUrl(RepoPage.Values[0]) then
    begin
      MsgBox(CustomMessage('InvalidRepository'), mbError, MB_OK);
      Result := False;
    end else if not IsSafeRef(Trim(RepoPage.Values[1])) then
    begin
      MsgBox(CustomMessage('InvalidRef'), mbError, MB_OK);
      Result := False;
    end;
  end else if CurPageID = PathsPage.ID then
  begin
    SteamSdk := PathsPage.Values[0];
    QtDir := PathsPage.Values[1];
    VulkanSdk := PathsPage.Values[2];
    Workspace := PathsPage.Values[3];
    Result := CheckFolder(SteamSdk, CustomMessage('SteamworksSdk')) and
      HasExpectedFile(SteamSdk, 'public\steam\steam_api.h', CustomMessage('SteamworksSdk')) and
      HasExpectedFile(SteamSdk, 'public\steam\isteamremoteplay.h', CustomMessage('SteamworksSdk')) and
      HasExpectedFile(SteamSdk, 'redistributable_bin\win64\steam_api64.lib', CustomMessage('SteamworksSdk')) and
      HasExpectedFile(SteamSdk, 'redistributable_bin\win64\steam_api64.dll', CustomMessage('SteamworksSdk'));
    if Result then
      Result := CheckFolder(QtDir, CustomMessage('QtDir')) and
        HasExpectedFile(QtDir, 'lib\cmake\Qt6\Qt6Config.cmake', CustomMessage('QtDir')) and
        HasExpectedFile(QtDir, 'lib\cmake\Qt6Charts\Qt6ChartsConfig.cmake', CustomMessage('QtDir')) and
        HasExpectedFile(QtDir, 'bin\windeployqt.exe', CustomMessage('QtDir'));
    if Result then
      Result := CheckFolder(VulkanSdk, CustomMessage('VulkanSdk')) and
        HasExpectedFile(VulkanSdk, 'Bin\glslangValidator.exe', CustomMessage('VulkanSdk'));
    if Result and IsDriveRoot(Workspace) then
    begin
      MsgBox(CustomMessage('RootWorkspace'), mbError, MB_OK);
      Result := False;
    end;
  end else if CurPageID = AppIdPage.ID then
  begin
    if not IsPositiveNumber(Trim(AppIdPage.Values[0])) then
    begin
      MsgBox(CustomMessage('InvalidAppId'), mbError, MB_OK);
      Result := False;
    end;
  end else if CurPageID = ConsentPage.ID then
  begin
    if not ConsentPage.Values[0] or not ConsentPage.Values[1] or not ConsentPage.Values[2] then
    begin
      MsgBox(CustomMessage('ConsentNeeded'), mbError, MB_OK);
      Result := False;
    end;
  end;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo,
  MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
begin
  Result := CustomMessage('ReviewRepository') + NewLine + Space + Trim(RepoPage.Values[0]) + NewLine +
    CustomMessage('ReviewReference') + NewLine + Space + Trim(RepoPage.Values[1]) + NewLine +
    CustomMessage('ReviewSteamworks') + NewLine + Space + PathsPage.Values[0] + NewLine +
    CustomMessage('ReviewQt') + NewLine + Space + PathsPage.Values[1] + NewLine +
    CustomMessage('ReviewVulkan') + NewLine + Space + PathsPage.Values[2] + NewLine +
    CustomMessage('ReviewWorkspace') + NewLine + Space + PathsPage.Values[3] + NewLine +
    CustomMessage('ReviewAppId') + NewLine + Space + Trim(AppIdPage.Values[0]) + NewLine + NewLine +
    CustomMessage('ReviewInstall') + NewLine + Space + ExpandConstant('{app}') + NewLine + NewLine +
    CustomMessage('ReviewSafe');
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ConfigPath, ScriptPath: String;
  ErrorCode: Integer;
begin
  if CurStep <> ssPostInstall then
    Exit;
  ConfigPath := ExpandConstant('{app}\BuildConfig.json');
  if not SaveBuildConfig(ConfigPath) then
  begin
    MsgBox('Could not save ' + ConfigPath + '.', mbError, MB_OK);
    Exit;
  end;
  if WizardSilent or not ConsentPage.Values[3] then
    Exit;
  ScriptPath := ExpandConstant('{app}\Run-Build.cmd');
  if ShellExecAsOriginalUser('open', ScriptPath, '"' + ConfigPath + '"',
       ExpandConstant('{app}'), SW_SHOWNORMAL, ewNoWait, ErrorCode) then
    BuildStarted := True
  else
    MsgBox(FmtMessage(CustomMessage('BuilderLaunchFailed'), [SysErrorMessage(ErrorCode), ExpandConstant('{app}')]), mbError, MB_OK);
end;
