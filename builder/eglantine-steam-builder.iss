; Eglantine Steam Remote Play Builder.
; It installs a local build helper, the source patch and Steam's runtime library (steam_api64.dll,
; a Steamworks redistributable that package-release.ps1 fetches and hash-checks). No Steamworks
; SDK is needed.

#define BuilderName "Eglantine Steam Remote Play Builder"
#define BuilderVersion "2.0.0"

[Setup]
AppId={{E28530FA-3AE1-45A8-913D-C61E27F86937}
AppName={#BuilderName}
AppVersion={#BuilderVersion}
AppVerName={#BuilderName} {#BuilderVersion}
VersionInfoVersion=2.0.0.0
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
english.WelcomeLabel2=This wizard makes a new, private Eglantine Windows build with Steam Remote Play Together.%n%nIt does not change an Eglantine folder you already use. Instead it downloads a source version or GitHub fork you choose, adds the Steam Remote Play Together extension, and builds a separate output folder.%n%nYou only need a Steam App ID you are authorized to use for Remote Play Together. The wizard checks your PC and gets the free tools for you, after asking.%n%nOnly build a repository you trust: building source code runs that repository's build instructions on your PC.
french.WelcomeLabel2=Cet assistant crée une nouvelle version Windows privée d'Eglantine avec Steam Remote Play Together.%n%nIl ne modifie pas votre dossier Eglantine existant. Il télécharge à la place la version du code source ou le fork GitHub de votre choix, ajoute l'extension Steam Remote Play Together, et crée un dossier de sortie séparé.%n%nVous n'avez besoin que d'un App ID Steam que vous êtes autorisé à utiliser pour Remote Play Together. L'assistant vérifie votre PC et récupère pour vous les outils gratuits, après vous avoir demandé.%n%nN'utilisez qu'un dépôt auquel vous faites confiance : compiler son code peut exécuter ses instructions de compilation sur votre PC.
english.FinishedHeadingLabel=The builder is ready
french.FinishedHeadingLabel=L'outil de compilation est prêt
english.FinishedLabelNoIcons=The builder is installed, but no build was started.%n%nTo build Eglantine later, run this installer again: it remembers your choices. Use only an App ID you own or are explicitly authorized to use.
french.FinishedLabelNoIcons=L'outil est installé, mais aucune compilation n'a été lancée.%n%nPour compiler Eglantine plus tard, relancez cet installateur : il se souvient de vos choix. Utilisez uniquement un App ID que vous possédez ou que vous êtes explicitement autorisé à utiliser.

[CustomMessages]
english.RepoCaption=Eglantine source
french.RepoCaption=Code source Eglantine
english.RepoDescription=Choose the public GitHub repository and its version
french.RepoDescription=Choisissez le dépôt GitHub public et sa version
english.RepoSubCaption=Use the official repository, or paste the HTTPS URL of an Eglantine fork. Then choose which version of its code to build.
french.RepoSubCaption=Utilisez le dépôt officiel, ou collez l'URL HTTPS d'un fork Eglantine. Choisissez ensuite la version de son code à compiler.
english.RepositoryUrl=GitHub repository URL:
french.RepositoryUrl=URL du dépôt GitHub :
english.GitRef=Version to build:
french.GitRef=Version à compiler :
english.RefKindBranch=&Branch
french.RefKindBranch=&Branche
english.RefKindTag=Release &tag
french.RefKindTag=&Tag de version
english.RefKindBranchCount=&Branch (%1)
french.RefKindBranchCount=&Branche (%1)
english.RefKindTagCount=Release &tag (%1)
french.RefKindTagCount=&Tag de version (%1)
english.RefKindBranchShort=branch
french.RefKindBranchShort=branche
english.RefKindTagShort=release tag
french.RefKindTagShort=tag de version
english.RefDefaultBranch=%1   (default branch)
french.RefDefaultBranch=%1   (branche par défaut)
english.RefreshRefs=&Refresh
french.RefreshRefs=&Actualiser
english.RefsLoading=Loading branches and tags from GitHub...
french.RefsLoading=Chargement des branches et tags depuis GitHub...
english.RefsBranchHelp=A branch is code still in development: it keeps changing and can be unstable.
french.RefsBranchHelp=Une branche contient du code en cours de développement : il évolue et peut être instable.
english.RefsTagHelp=A release tag is a fixed, published version: it never changes.
french.RefsTagHelp=Un tag de version est une version publiée et figée : il ne change jamais.
english.RefsNoTags=This repository has no release tags. Choose a branch.
french.RefsNoTags=Ce dépôt n'a aucun tag de version. Choisissez une branche.
english.RefsNoBranches=This repository has no branches. Choose a release tag.
french.RefsNoBranches=Ce dépôt n'a aucune branche. Choisissez un tag de version.
english.RefsFailed=Could not load the list (%1). Check the URL and your connection, then click Refresh. You can also type a branch or tag name.
french.RefsFailed=Impossible de charger la liste (%1). Vérifiez l'URL et votre connexion, puis cliquez sur Actualiser. Vous pouvez aussi saisir un nom de branche ou de tag.
english.RefsUrlChanged=The repository URL changed. Its list loads when you leave the URL field, or click Refresh.
french.RefsUrlChanged=L'URL du dépôt a changé. Sa liste se charge quand vous quittez le champ URL, ou cliquez sur Actualiser.
english.RefsInvalidUrl=Enter a GitHub repository URL above to load its branches and tags.
french.RefsInvalidUrl=Entrez une URL de dépôt GitHub ci-dessus pour charger ses branches et tags.
english.RefsNotChosen=Choose a branch or release tag to build.
french.RefsNotChosen=Choisissez une branche ou un tag de version à compiler.
english.ReqCaption=Checking your PC
french.ReqCaption=Vérification de votre PC
english.ReqDescription=The wizard checks what the build needs and gets anything missing for you
french.ReqDescription=L'assistant vérifie ce dont la compilation a besoin et récupère ce qui manque
english.ReqSubCaption=Nothing is installed until you click Finish. Free tools that are missing are downloaded into the build folder below, so they do not change the rest of your PC.
french.ReqSubCaption=Rien n'est installé avant que vous cliquiez sur Terminer. Les outils gratuits manquants sont téléchargés dans le dossier de compilation ci-dessous, sans modifier le reste de votre PC.
english.Workspace=Build folder (needs about 15 GB):
french.Workspace=Dossier de compilation (environ 15 Go nécessaires) :
english.Browse=B&rowse...
french.Browse=&Parcourir...
english.Recheck=Check a&gain
french.Recheck=&Vérifier à nouveau
english.ReqChecking=Checking...
french.ReqChecking=Vérification...
english.ReqCheckFailed=The check could not run (%1). Click Check again.
french.ReqCheckFailed=La vérification n'a pas pu s'exécuter (%1). Cliquez sur Vérifier à nouveau.
english.ReqWindowsOk=%1
french.ReqWindowsOk=%1
english.ReqWindowsBad=%1: this builder needs 64-bit Windows 10 or 11.
french.ReqWindowsBad=%1 : cet outil nécessite Windows 10 ou 11 en 64 bits.
english.ReqVsOk=Microsoft C++ compiler: %1
french.ReqVsOk=Compilateur Microsoft C++ : %1
english.ReqVsMissing=Microsoft C++ compiler: not installed. It can be installed for you (free, about 8 GB, Windows asks for administrator approval once).
french.ReqVsMissing=Compilateur Microsoft C++ : non installé. Il peut être installé pour vous (gratuit, environ 8 Go, Windows demande une autorisation administrateur une fois).
english.ReqVsOld=Microsoft C++ compiler: %1 is too old. A current version can be installed for you (free, about 8 GB).
french.ReqVsOld=Compilateur Microsoft C++ : %1 est trop ancien. Une version récente peut être installée pour vous (gratuit, environ 8 Go).
english.ReqGitOk=Git (downloads the source code): installed
french.ReqGitOk=Git (télécharge le code source) : installé
english.ReqGitDownload=Git (downloads the source code): will be downloaded automatically (40 MB)
french.ReqGitDownload=Git (télécharge le code source) : sera téléchargé automatiquement (40 Mo)
english.ReqQtOk=Qt %1 (user interface library): ready
french.ReqQtOk=Qt %1 (bibliothèque d'interface) : prêt
english.ReqQtDownload=Qt %1 (user interface library): will be downloaded automatically (about 1 GB)
french.ReqQtDownload=Qt %1 (bibliothèque d'interface) : sera téléchargé automatiquement (environ 1 Go)
english.ReqQtOwn=Qt: your own folder (advanced settings)
french.ReqQtOwn=Qt : votre propre dossier (réglages avancés)
english.ReqGlslangOk=Shader compiler (glslang %1): ready
french.ReqGlslangOk=Compilateur de shaders (glslang %1) : prêt
english.ReqGlslangDownload=Shader compiler (glslang %1): will be downloaded automatically (15 MB)
french.ReqGlslangDownload=Compilateur de shaders (glslang %1) : sera téléchargé automatiquement (15 Mo)
english.ReqGlslangOwn=Shader compiler: from your Vulkan SDK (advanced settings)
french.ReqGlslangOwn=Compilateur de shaders : depuis votre SDK Vulkan (réglages avancés)
english.ReqSpaceOk=Free space: %1 GB available (%2 GB needed)
french.ReqSpaceOk=Espace libre : %1 Go disponibles (%2 Go nécessaires)
english.ReqSpaceLow=Free space: only %1 GB available, %2 GB needed. Choose a folder on another drive or free some space.
french.ReqSpaceLow=Espace libre : seulement %1 Go disponibles, %2 Go nécessaires. Choisissez un dossier sur un autre disque ou libérez de l'espace.
english.InstallVs=&Install the Microsoft C++ compiler for me
french.InstallVs=&Installer le compilateur Microsoft C++ pour moi
english.UseOwnTools=Ad&vanced: use my own Qt or Vulkan SDK folders
french.UseOwnTools=A&vancé : utiliser mes propres dossiers Qt ou SDK Vulkan
english.NeedVsInstall=The Microsoft C++ compiler is needed to build Eglantine.%n%nTick "Install the Microsoft C++ compiler for me", or install "Desktop development with C++" from visualstudio.microsoft.com and click Check again.
french.NeedVsInstall=Le compilateur Microsoft C++ est nécessaire pour compiler Eglantine.%n%nCochez « Installer le compilateur Microsoft C++ pour moi », ou installez « Développement Desktop en C++ » depuis visualstudio.microsoft.com puis cliquez sur Vérifier à nouveau.
english.NeedSpace=There is not enough free space for the build folder:%n%n%1 GB available, %2 GB needed.
french.NeedSpace=Il n'y a pas assez d'espace libre pour le dossier de compilation :%n%n%1 Go disponibles, %2 Go nécessaires.
english.NeedWindows=This builder needs 64-bit Windows 10 or Windows 11.
french.NeedWindows=Cet outil nécessite Windows 10 ou Windows 11 en 64 bits.
english.NeedCheck=The PC check has not finished. Click Check again.
french.NeedCheck=La vérification du PC n'est pas terminée. Cliquez sur Vérifier à nouveau.
english.NeedWorkspace=Choose a build folder.
french.NeedWorkspace=Choisissez un dossier de compilation.
english.AdvancedCaption=Your own tool folders
french.AdvancedCaption=Vos propres dossiers d'outils
english.AdvancedDescription=Only for advanced users
french.AdvancedDescription=Réservé aux utilisateurs avancés
english.AdvancedSubCaption=Leave a field empty to let the builder download the tested version automatically.
french.AdvancedSubCaption=Laissez un champ vide pour que l'outil télécharge automatiquement la version testée.
english.QtDir=Qt MSVC 2022 64-bit folder with Qt Charts (6.8.3 tested), or empty:
french.QtDir=Dossier Qt MSVC 2022 64-bit avec Qt Charts (6.8.3 testé), ou vide :
english.VulkanSdk=Vulkan SDK folder, or empty:
french.VulkanSdk=Dossier du SDK Vulkan, ou vide :
english.Automatic=downloaded automatically
french.Automatic=téléchargé automatiquement
english.ReviewInstallVs=Install the Microsoft C++ compiler:
french.ReviewInstallVs=Installer le compilateur Microsoft C++ :
english.Yes=yes
french.Yes=oui
english.BuildCaption=Building Eglantine
french.BuildCaption=Compilation d'Eglantine
english.BuildDescription=You can keep using your PC. The first build can take one to two hours.
french.BuildDescription=Vous pouvez continuer à utiliser votre PC. La première compilation peut prendre une à deux heures.
english.BuildStarting=Starting the build...
french.BuildStarting=Démarrage de la compilation...
english.BuildStep=Step %1 of %2: %3
french.BuildStep=Étape %1 sur %2 : %3
english.BuildElapsed=Elapsed time: %1
french.BuildElapsed=Temps écoulé : %1
english.BuildStop=&Stop the build
french.BuildStop=&Arrêter la compilation
english.BuildStopConfirm=Stop the build now?%n%nYou can start it again later by running this installer again. Downloads already done are kept.
french.BuildStopConfirm=Arrêter la compilation maintenant ?%n%nVous pourrez la relancer plus tard en relançant cet installateur. Les téléchargements déjà faits sont conservés.
english.BuildStopped=The build was stopped.
french.BuildStopped=La compilation a été arrêtée.
english.BuildDone=Done! Your private Eglantine build is ready.
french.BuildDone=Terminé ! Votre compilation privée d'Eglantine est prête.
english.BuildFailed=The build failed: %1
french.BuildFailed=La compilation a échoué : %1
english.BuildNoStart=The build could not start (%1).
french.BuildNoStart=La compilation n'a pas pu démarrer (%1).
english.BuildNoStatus=no progress was reported
french.BuildNoStatus=aucune progression n'a été signalée
english.BuildVanished=The build stopped unexpectedly. Open the log to see the last messages.
french.BuildVanished=La compilation s'est arrêtée de façon inattendue. Ouvrez le journal pour voir les derniers messages.
english.BuildOpenFolder=&Open the build folder
french.BuildOpenFolder=&Ouvrir le dossier de la compilation
english.BuildOpenLog=Open the &log
french.BuildOpenLog=Ouvrir le &journal
english.BuildStillRunning=The build is still running. Stop it first with "Stop the build".
french.BuildStillRunning=La compilation est toujours en cours. Arrêtez-la d'abord avec « Arrêter la compilation ».
english.FinishedDone=Your private Eglantine build is in:%n%n%1%n%nStart Steam, then start eglantine.exe from that folder. The first time, open Extensions > Manage Extensions..., tick Steam Remote Play Together, and restart Eglantine.%n%nThe README.txt in that folder explains the rest.
french.FinishedDone=Votre compilation privée d'Eglantine se trouve dans :%n%n%1%n%nDémarrez Steam, puis lancez eglantine.exe depuis ce dossier. La première fois, ouvrez Extensions > Manage Extensions..., cochez Steam Remote Play Together, puis redémarrez Eglantine.%n%nLe fichier README.txt de ce dossier explique la suite.
english.FinishedFailed=The build did not finish:%n%n%1%n%nFix the problem, then run this installer again: it remembers your choices and keeps what was already downloaded.%n%nLog: %2
french.FinishedFailed=La compilation ne s'est pas terminée :%n%n%1%n%nCorrigez le problème, puis relancez cet installateur : il se souvient de vos choix et conserve ce qui a déjà été téléchargé.%n%nJournal : %2
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
english.ConsentAppId=I am authorized to use the App ID above, and it is configured for Remote Play Together.
french.ConsentAppId=Je suis autorisé à utiliser l'App ID ci-dessus, et il est configuré pour Remote Play Together.
english.StartBuild=Build Eglantine right after this step, with the progress shown in this window (recommended).
french.StartBuild=Compiler Eglantine juste après cette étape, avec la progression affichée dans cette fenêtre (recommandé).
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
english.ConsentNeeded=Tick the two confirmation boxes before continuing.
french.ConsentNeeded=Cochez les deux cases de confirmation avant de continuer.
english.BuilderLaunchFailed=The builder was installed, but Windows could not start its build window:%n%n%1%n%nOpen this folder and double-click Run-Build.cmd:%n%n%2
french.BuilderLaunchFailed=L'outil a été installé, mais Windows n'a pas pu démarrer la fenêtre de compilation :%n%n%1%n%nOuvrez ce dossier et double-cliquez sur Run-Build.cmd :%n%n%2
english.ReviewRepository=Repository:
french.ReviewRepository=Dépôt :
english.ReviewReference=Reference:
french.ReviewReference=Référence :
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
Source: "payload\List-GitRefs.ps1"; Flags: dontcopy
Source: "payload\Check-Requirements.ps1"; Flags: dontcopy
Source: "payload\steam-remote-play-together.patch"; DestDir: "{app}"; Flags: ignoreversion
; Valve's Steamworks redistributable, fetched and hash-checked by package-release.ps1 (never committed).
Source: "payload\steam_api64.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "payload\README-en.txt"; DestDir: "{app}"; DestName: "README.txt"; Languages: english; Flags: ignoreversion
Source: "payload\README-fr.txt"; DestDir: "{app}"; DestName: "README.txt"; Languages: french; Flags: ignoreversion

[UninstallDelete]
Type: files; Name: "{app}\BuildConfig.json"

[Run]
Filename: "{app}\README.txt"; Description: "{cm:OpenReadme}"; Flags: postinstall shellexec skipifsilent unchecked nowait

[Code]
var
  RepoPage: TInputQueryWizardPage;
  ReqPage: TWizardPage;
  AdvancedPage: TInputDirWizardPage;
  WorkspaceEdit: TNewEdit;
  WorkspaceBrowseButton, RecheckButton: TNewButton;
  ReqMarks, ReqTexts: array[0..5] of TNewStaticText;
  InstallVsCheck, OwnToolsCheck: TNewCheckBox;
  ReqDone, ReqWindowsOk, ReqVsOk, ReqSpaceOk: Boolean;
  ReqFreeGB, ReqNeededGB, ReqCheckedWorkspace: String;
  BuildPage: TWizardPage;
  BuildStepLabel, BuildHintLabel, BuildElapsedLabel, BuildResultLabel: TNewStaticText;
  BuildProgress: TNewProgressBar;
  BuildMemo: TNewMemo;
  BuildStopButton, BuildOpenFolderButton, BuildOpenLogButton: TNewButton;
  BuildState, BuildResult, BuildLogPath, BuildStatusPath, BuildLastTail: String;
  BuildPid, BuildStartTick: DWORD;
  BuildTimer: UINT_PTR;
  ConfigSaved: Boolean;
  AppIdPage: TInputQueryWizardPage;
  ConsentPage: TInputOptionWizardPage;
  RefCombo: TNewComboBox;
  RefreshRefsButton: TNewButton;
  RefStatusText: TNewStaticText;
  BranchRadio, TagRadio: TNewRadioButton;
  BranchNames, TagNames: TArrayOfString;
  DefaultBranchName, LastBranchChoice, LastTagChoice, PreviousRefKind: String;
  LoadedRefsUrl: String;
  RefsListed, UpdatingRefs: Boolean;
  BuildStarted: Boolean;

function IsGitHubRepositoryUrl(const Value: String): Boolean;
var
  Lower: String;
begin
  Lower := Lowercase(Trim(Value));
  Result := (Pos('https://github.com/', Lower) = 1) and
            (Pos('?', Lower) = 0) and (Pos('#', Lower) = 0) and
            (Pos(' ', Lower) = 0) and (Pos('\', Lower) = 0) and
            (Pos('"', Lower) = 0);
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

function IndexOfName(const Names: TArrayOfString; const Name: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to GetArrayLength(Names) - 1 do
    if Names[I] = Name then
    begin
      Result := I;
      Exit;
    end;
end;

procedure AppendName(var Names: TArrayOfString; const Name: String);
var
  Count: Integer;
begin
  Count := GetArrayLength(Names);
  SetArrayLength(Names, Count + 1);
  Names[Count] := Name;
end;

// '' while the list is not loaded and the name was typed by hand.
function GetGitRefKind(): String;
begin
  if not RefsListed then
    Result := ''
  else if TagRadio.Checked then
    Result := 'tag'
  else
    Result := 'branch';
end;

function GetGitRef(): String;
begin
  Result := '';
  if not RefsListed then
    Result := Trim(RefCombo.Text)
  else if RefCombo.ItemIndex >= 0 then
  begin
    if TagRadio.Checked then
      Result := TagNames[RefCombo.ItemIndex]
    else
      Result := BranchNames[RefCombo.ItemIndex];
  end;
end;

procedure UpdateRefHelp();
begin
  if not RefsListed then
    Exit;
  if TagRadio.Checked then
  begin
    if GetArrayLength(TagNames) = 0 then
      RefStatusText.Caption := CustomMessage('RefsNoTags')
    else
      RefStatusText.Caption := CustomMessage('RefsTagHelp');
  end else
  begin
    if GetArrayLength(BranchNames) = 0 then
      RefStatusText.Caption := CustomMessage('RefsNoBranches')
    else
      RefStatusText.Caption := CustomMessage('RefsBranchHelp');
  end;
end;

// Shows the names of the selected kind and selects Wanted, or the first entry.
procedure FillRefCombo(const Wanted: String);
var
  I, Index: Integer;
begin
  RefCombo.Items.Clear;
  if TagRadio.Checked then
  begin
    for I := 0 to GetArrayLength(TagNames) - 1 do
      RefCombo.Items.Add(TagNames[I]);
    Index := IndexOfName(TagNames, Wanted);
  end else
  begin
    for I := 0 to GetArrayLength(BranchNames) - 1 do
      if BranchNames[I] = DefaultBranchName then
        RefCombo.Items.Add(FmtMessage(CustomMessage('RefDefaultBranch'), [BranchNames[I]]))
      else
        RefCombo.Items.Add(BranchNames[I]);
    Index := IndexOfName(BranchNames, Wanted);
  end;
  if (Index < 0) and (RefCombo.Items.Count > 0) then
    Index := 0;
  RefCombo.ItemIndex := Index;
  RefCombo.Enabled := RefCombo.Items.Count > 0;
  UpdateRefHelp();
end;

procedure RefComboChange(Sender: TObject);
begin
  if UpdatingRefs or not RefsListed then
    Exit;
  if TagRadio.Checked then
    LastTagChoice := GetGitRef()
  else
    LastBranchChoice := GetGitRef();
end;

procedure RefKindClick(Sender: TObject);
begin
  if UpdatingRefs or not RefsListed then
    Exit;
  if TagRadio.Checked then
    FillRefCombo(LastTagChoice)
  else
    FillRefCombo(LastBranchChoice);
end;

// Without a list, the field accepts a typed branch or tag name.
procedure SetManualRefMode(const Name: String);
begin
  RefsListed := False;
  RefCombo.Style := csDropDown;
  RefCombo.Items.Clear;
  RefCombo.Enabled := True;
  RefCombo.Text := Name;
  BranchRadio.Caption := CustomMessage('RefKindBranch');
  TagRadio.Caption := CustomMessage('RefKindTag');
  BranchRadio.Enabled := False;
  TagRadio.Enabled := False;
end;

// Loads the branches and tags of the repository URL. The helper reads GitHub's public Git ref
// list; if it fails, the field falls back to a typed name.
procedure LoadGitRefs(Force: Boolean);
var
  Url, Current, CurrentKind, DefaultBranch, Line, Kind, Name, Detail, Wanted: String;
  Output: TExecOutput;
  Branches, Tags: TArrayOfString;
  ResultCode, I, SpacePos: Integer;
  Loaded, UseTags: Boolean;
begin
  Url := Trim(RepoPage.Values[0]);
  if not IsGitHubRepositoryUrl(Url) then
  begin
    RefStatusText.Caption := CustomMessage('RefsInvalidUrl');
    Exit;
  end;
  if (not Force) and (Url = LoadedRefsUrl) then
    Exit;

  Current := GetGitRef();
  CurrentKind := GetGitRefKind();
  if CurrentKind = '' then
    CurrentKind := PreviousRefKind;

  RefStatusText.Caption := CustomMessage('RefsLoading');
  RefreshRefsButton.Enabled := False;
  WizardForm.NextButton.Enabled := False;
  try
    ExtractTemporaryFile('List-GitRefs.ps1');
    Loaded := ExecAndCaptureOutput(ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe'),
      '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' +
      ExpandConstant('{tmp}\List-GitRefs.ps1') + '" -RepositoryUrl "' + Url + '"',
      ExpandConstant('{tmp}'), SW_HIDE, ewWaitUntilTerminated, ResultCode, Output) and
      (ResultCode = 0) and (GetArrayLength(Output.StdOut) > 0);

    if not Loaded then
    begin
      Detail := '';
      if GetArrayLength(Output.StdErr) > 0 then
        Detail := Trim(Output.StdErr[0]);
      if Detail = '' then
        Detail := 'exit code ' + IntToStr(ResultCode);
      LoadedRefsUrl := '';
      SetManualRefMode(Current);
      RefStatusText.Caption := FmtMessage(CustomMessage('RefsFailed'), [Detail]);
      Exit;
    end;

    DefaultBranch := '';
    SetArrayLength(Branches, 0);
    SetArrayLength(Tags, 0);
    for I := 0 to GetArrayLength(Output.StdOut) - 1 do
    begin
      Line := Trim(Output.StdOut[I]);
      SpacePos := Pos(' ', Line);
      if SpacePos = 0 then
        Continue;
      Kind := Copy(Line, 1, SpacePos - 1);
      Name := Trim(Copy(Line, SpacePos + 1, Length(Line)));
      if not IsSafeRef(Name) then
        Continue;
      if Kind = 'default' then
        DefaultBranch := Name
      else if Kind = 'branch' then
        AppendName(Branches, Name)
      else if Kind = 'tag' then
        AppendName(Tags, Name);
    end;

    // The default branch goes first, then the other branches in name order.
    SetArrayLength(BranchNames, 0);
    if IndexOfName(Branches, DefaultBranch) >= 0 then
      AppendName(BranchNames, DefaultBranch)
    else
      DefaultBranch := '';
    for I := 0 to GetArrayLength(Branches) - 1 do
      if Branches[I] <> DefaultBranch then
        AppendName(BranchNames, Branches[I]);
    TagNames := Tags;
    DefaultBranchName := DefaultBranch;

    // Keep the current choice when this repository has it; otherwise use its default branch.
    Wanted := '';
    if (CurrentKind = 'tag') and (IndexOfName(TagNames, Current) >= 0) then
    begin
      UseTags := True;
      Wanted := Current;
    end else if IndexOfName(BranchNames, Current) >= 0 then
    begin
      UseTags := False;
      Wanted := Current;
    end else if IndexOfName(TagNames, Current) >= 0 then
    begin
      UseTags := True;
      Wanted := Current;
    end else
      UseTags := GetArrayLength(BranchNames) = 0;

    UpdatingRefs := True;
    try
      RefsListed := True;
      RefCombo.Style := csDropDownList;
      BranchRadio.Caption := FmtMessage(CustomMessage('RefKindBranchCount'), [IntToStr(GetArrayLength(BranchNames))]);
      TagRadio.Caption := FmtMessage(CustomMessage('RefKindTagCount'), [IntToStr(GetArrayLength(TagNames))]);
      BranchRadio.Enabled := True;
      TagRadio.Enabled := True;
      BranchRadio.Checked := not UseTags;
      TagRadio.Checked := UseTags;
      if UseTags then
      begin
        LastTagChoice := Wanted;
        LastBranchChoice := '';
      end else
      begin
        LastBranchChoice := Wanted;
        LastTagChoice := '';
      end;
      FillRefCombo(Wanted);
    finally
      UpdatingRefs := False;
    end;
    LoadedRefsUrl := Url;
  finally
    RefreshRefsButton.Enabled := True;
    WizardForm.NextButton.Enabled := True;
  end;
end;

procedure RefreshRefsButtonClick(Sender: TObject);
begin
  LoadGitRefs(True);
end;

procedure RepoUrlChange(Sender: TObject);
begin
  if (LoadedRefsUrl <> '') and (Trim(RepoPage.Values[0]) <> LoadedRefsUrl) then
    RefStatusText.Caption := CustomMessage('RefsUrlChanged');
end;

procedure RepoUrlExit(Sender: TObject);
begin
  LoadGitRefs(False);
end;

// ---------------------------------------------------------------------------------------------
// Helpers shared by the requirement pages.

// Runs a bundled read-only PowerShell helper and returns its output lines.
function RunHelper(const ScriptName, Params: String; var Lines: TArrayOfString; var ErrorText: String): Boolean;
var
  Output: TExecOutput;
  ResultCode: Integer;
begin
  ErrorText := '';
  ExtractTemporaryFile(ScriptName);
  Result := ExecAndCaptureOutput(ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe'),
    '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' + ExpandConstant('{tmp}\') + ScriptName + '" ' + Params,
    ExpandConstant('{tmp}'), SW_HIDE, ewWaitUntilTerminated, ResultCode, Output) and
    (ResultCode = 0) and (GetArrayLength(Output.StdOut) > 0);
  if Result then
    Lines := Output.StdOut
  else
  begin
    if GetArrayLength(Output.StdErr) > 0 then
      ErrorText := Trim(Output.StdErr[0]);
    if ErrorText = '' then
      ErrorText := 'exit code ' + IntToStr(ResultCode);
  end;
end;

// Windows paths cannot contain quotes; a trailing backslash would escape the closing quote.
function QuoteArg(const Value: String): String;
begin
  Result := '"' + RemoveBackslash(Trim(Value)) + '"';
end;

// Returns the text before the next '|' and removes it from Line.
function NextField(var Line: String): String;
var
  P: Integer;
begin
  P := Pos('|', Line);
  if P = 0 then
  begin
    Result := Line;
    Line := '';
  end else
  begin
    Result := Copy(Line, 1, P - 1);
    Line := Copy(Line, P + 1, Length(Line));
  end;
end;

function IsFrench(): Boolean;
begin
  Result := ActiveLanguage = 'french';
end;

function GetOwnQtDir(): String;
begin
  Result := '';
  if OwnToolsCheck.Checked then
    Result := Trim(AdvancedPage.Values[0]);
end;

function GetOwnVulkanSdk(): String;
begin
  Result := '';
  if OwnToolsCheck.Checked then
    Result := Trim(AdvancedPage.Values[1]);
end;

function GetWorkspace(): String;
begin
  Result := RemoveBackslashUnlessRoot(Trim(WorkspaceEdit.Text));
end;

function InstallMissingTools(): Boolean;
begin
  Result := (not ReqVsOk) and InstallVsCheck.Checked;
end;

// ---------------------------------------------------------------------------------------------
// "Checking your PC" page.

const
  ReqWindows = 0;
  ReqVs = 1;
  ReqGit = 2;
  ReqQt = 3;
  ReqGlslang = 4;
  ReqSpace = 5;
  ReqCount = 6;
  MarkOk = 0;
  MarkAuto = 1;
  MarkProblem = 2;

procedure LayoutRequirementsPage();
var
  I, Y: Integer;
begin
  Y := WorkspaceEdit.Top + WorkspaceEdit.Height + ScaleY(12);
  for I := 0 to ReqCount - 1 do
  begin
    ReqMarks[I].Top := Y;
    ReqTexts[I].Top := Y;
    ReqTexts[I].AdjustHeight();
    Y := Y + ReqTexts[I].Height + ScaleY(5);
  end;
  InstallVsCheck.Top := Y + ScaleY(2);
end;

procedure SetRequirement(Index, Mark: Integer; const Text: String);
begin
  case Mark of
    MarkOk:
      begin
        ReqMarks[Index].Caption := #$2714;
        ReqMarks[Index].Font.Color := $00007F00;
      end;
    MarkAuto:
      begin
        ReqMarks[Index].Caption := #$2B07;
        ReqMarks[Index].Font.Color := $00B05000;
      end;
  else
    begin
      ReqMarks[Index].Caption := #$2716;
      ReqMarks[Index].Font.Color := $000000C0;
    end;
  end;
  ReqTexts[Index].Caption := Text;
end;

procedure ApplyRequirementLine(Line: String);
var
  Key, Status, Detail, FreeGB: String;
  SlashPos: Integer;
begin
  Key := NextField(Line);
  Status := NextField(Line);
  Detail := Trim(Line);
  if Key = 'windows' then
  begin
    ReqWindowsOk := Status = 'ok';
    if ReqWindowsOk then
      SetRequirement(ReqWindows, MarkOk, FmtMessage(CustomMessage('ReqWindowsOk'), [Detail]))
    else
      SetRequirement(ReqWindows, MarkProblem, FmtMessage(CustomMessage('ReqWindowsBad'), [Detail]));
  end else if Key = 'vs' then
  begin
    ReqVsOk := Status = 'ok';
    if ReqVsOk then
      SetRequirement(ReqVs, MarkOk, FmtMessage(CustomMessage('ReqVsOk'), [Detail]))
    else if Status = 'old' then
      SetRequirement(ReqVs, MarkProblem, FmtMessage(CustomMessage('ReqVsOld'), [Detail]))
    else
      SetRequirement(ReqVs, MarkProblem, CustomMessage('ReqVsMissing'));
    InstallVsCheck.Visible := not ReqVsOk;
  end else if Key = 'git' then
  begin
    if Status = 'ok' then
      SetRequirement(ReqGit, MarkOk, CustomMessage('ReqGitOk'))
    else
      SetRequirement(ReqGit, MarkAuto, CustomMessage('ReqGitDownload'));
  end else if Key = 'qt' then
  begin
    if GetOwnQtDir() <> '' then
      SetRequirement(ReqQt, MarkOk, CustomMessage('ReqQtOwn'))
    else if Status = 'ok' then
      SetRequirement(ReqQt, MarkOk, FmtMessage(CustomMessage('ReqQtOk'), [Detail]))
    else
      SetRequirement(ReqQt, MarkAuto, FmtMessage(CustomMessage('ReqQtDownload'), [Detail]));
  end else if Key = 'glslang' then
  begin
    if GetOwnVulkanSdk() <> '' then
      SetRequirement(ReqGlslang, MarkOk, CustomMessage('ReqGlslangOwn'))
    else if Status = 'ok' then
      SetRequirement(ReqGlslang, MarkOk, FmtMessage(CustomMessage('ReqGlslangOk'), [Detail]))
    else
      SetRequirement(ReqGlslang, MarkAuto, FmtMessage(CustomMessage('ReqGlslangDownload'), [Detail]));
  end else if Key = 'space' then
  begin
    SlashPos := Pos('/', Detail);
    FreeGB := Copy(Detail, 1, SlashPos - 1);
    ReqFreeGB := FreeGB;
    ReqNeededGB := Copy(Detail, SlashPos + 1, Length(Detail));
    ReqSpaceOk := Status = 'ok';
    if ReqSpaceOk then
      SetRequirement(ReqSpace, MarkOk, FmtMessage(CustomMessage('ReqSpaceOk'), [ReqFreeGB, ReqNeededGB]))
    else
      SetRequirement(ReqSpace, MarkProblem, FmtMessage(CustomMessage('ReqSpaceLow'), [ReqFreeGB, ReqNeededGB]));
  end;
end;

procedure RunRequirementCheck();
var
  Lines: TArrayOfString;
  ErrorText, Params: String;
  I: Integer;
begin
  ReqDone := False;
  ReqWindowsOk := False;
  ReqVsOk := False;
  ReqSpaceOk := False;
  for I := 0 to ReqCount - 1 do
  begin
    ReqMarks[I].Caption := '';
    ReqTexts[I].Caption := '';
  end;
  ReqTexts[0].Caption := CustomMessage('ReqChecking');
  LayoutRequirementsPage();
  RecheckButton.Enabled := False;
  WizardForm.NextButton.Enabled := False;
  try
    Params := '-Mode System';
    if GetWorkspace() <> '' then
      Params := Params + ' -Workspace ' + QuoteArg(GetWorkspace());
    if RunHelper('Check-Requirements.ps1', Params, Lines, ErrorText) then
    begin
      for I := 0 to GetArrayLength(Lines) - 1 do
        ApplyRequirementLine(Trim(Lines[I]));
      ReqDone := True;
      ReqCheckedWorkspace := GetWorkspace();
    end else
      SetRequirement(ReqWindows, MarkProblem, FmtMessage(CustomMessage('ReqCheckFailed'), [ErrorText]));
  finally
    RecheckButton.Enabled := True;
    WizardForm.NextButton.Enabled := True;
  end;
  LayoutRequirementsPage();
end;

procedure RecheckButtonClick(Sender: TObject);
begin
  RunRequirementCheck();
end;

procedure WorkspaceBrowseClick(Sender: TObject);
var
  Folder: String;
begin
  Folder := GetWorkspace();
  if BrowseForFolder(CustomMessage('Workspace'), Folder, True) then
  begin
    WorkspaceEdit.Text := Folder;
    RunRequirementCheck();
  end;
end;

function CheckRequirementsPage(): Boolean;
begin
  Result := False;
  if GetWorkspace() = '' then
  begin
    MsgBox(CustomMessage('NeedWorkspace'), mbError, MB_OK);
    Exit;
  end;
  if IsDriveRoot(GetWorkspace()) then
  begin
    MsgBox(CustomMessage('RootWorkspace'), mbError, MB_OK);
    Exit;
  end;
  if (not ReqDone) or (GetWorkspace() <> ReqCheckedWorkspace) then
    RunRequirementCheck();
  if not ReqDone then
    MsgBox(CustomMessage('NeedCheck'), mbError, MB_OK)
  else if not ReqWindowsOk then
    MsgBox(CustomMessage('NeedWindows'), mbError, MB_OK)
  else if not ReqSpaceOk then
    MsgBox(FmtMessage(CustomMessage('NeedSpace'), [ReqFreeGB, ReqNeededGB]), mbError, MB_OK)
  else if (not ReqVsOk) and (not InstallVsCheck.Checked) then
    MsgBox(CustomMessage('NeedVsInstall'), mbError, MB_OK)
  else
    Result := True;
end;

// ---------------------------------------------------------------------------------------------
// Page creation.

procedure CreateRequirementsPage(AfterID: Integer);
var
  WorkspaceLabel: TNewStaticText;
  I: Integer;
begin
  ReqPage := CreateCustomPage(AfterID, CustomMessage('ReqCaption'), CustomMessage('ReqDescription'));

  WorkspaceLabel := TNewStaticText.Create(ReqPage);
  WorkspaceLabel.Parent := ReqPage.Surface;
  WorkspaceLabel.Caption := CustomMessage('Workspace');
  WorkspaceLabel.Top := 0;

  // The edit is created first so it gets the keyboard focus (and Enter still means Next).
  WorkspaceEdit := TNewEdit.Create(ReqPage);
  WorkspaceEdit.Parent := ReqPage.Surface;
  WorkspaceEdit.Top := WorkspaceLabel.Top + WorkspaceLabel.Height + ScaleY(4);
  WorkspaceEdit.Width := ReqPage.SurfaceWidth - ScaleX(98);
  WorkspaceEdit.Text := GetPreviousData('Workspace', ExpandConstant('{userdocs}\Eglantine Steam Builds'));
  WorkspaceLabel.FocusControl := WorkspaceEdit;
  WorkspaceBrowseButton := TNewButton.Create(ReqPage);
  WorkspaceBrowseButton.Parent := ReqPage.Surface;
  WorkspaceBrowseButton.Caption := CustomMessage('Browse');
  WorkspaceBrowseButton.Width := ScaleX(90);
  WorkspaceBrowseButton.Left := ReqPage.SurfaceWidth - WorkspaceBrowseButton.Width;
  WorkspaceBrowseButton.OnClick := @WorkspaceBrowseClick;
  WorkspaceBrowseButton.Top := WorkspaceEdit.Top - ScaleY(1);
  WorkspaceBrowseButton.Height := WorkspaceEdit.Height + ScaleY(2);

  for I := 0 to ReqCount - 1 do
  begin
    ReqMarks[I] := TNewStaticText.Create(ReqPage);
    ReqMarks[I].Parent := ReqPage.Surface;
    ReqMarks[I].Font.Name := 'Segoe UI Symbol';
    ReqMarks[I].Font.Style := [fsBold];
    ReqMarks[I].Left := 0;
    ReqMarks[I].Caption := '';

    ReqTexts[I] := TNewStaticText.Create(ReqPage);
    ReqTexts[I].Parent := ReqPage.Surface;
    ReqTexts[I].AutoSize := False;
    ReqTexts[I].WordWrap := True;
    ReqTexts[I].Left := ScaleX(20);
    ReqTexts[I].Width := ReqPage.SurfaceWidth - ScaleX(20);
    ReqTexts[I].Caption := '';
  end;

  InstallVsCheck := TNewCheckBox.Create(ReqPage);
  InstallVsCheck.Parent := ReqPage.Surface;
  InstallVsCheck.Caption := CustomMessage('InstallVs');
  InstallVsCheck.Left := ScaleX(20);
  InstallVsCheck.Width := ReqPage.SurfaceWidth - ScaleX(20);
  InstallVsCheck.Checked := True;
  InstallVsCheck.Visible := False;

  RecheckButton := TNewButton.Create(ReqPage);
  RecheckButton.Parent := ReqPage.Surface;
  RecheckButton.Caption := CustomMessage('Recheck');
  RecheckButton.Width := ScaleX(130);
  RecheckButton.Height := WorkspaceBrowseButton.Height;
  RecheckButton.Left := ReqPage.SurfaceWidth - RecheckButton.Width;
  RecheckButton.Top := ReqPage.SurfaceHeight - RecheckButton.Height;
  RecheckButton.OnClick := @RecheckButtonClick;

  OwnToolsCheck := TNewCheckBox.Create(ReqPage);
  OwnToolsCheck.Parent := ReqPage.Surface;
  OwnToolsCheck.Caption := CustomMessage('UseOwnTools');
  OwnToolsCheck.Left := 0;
  OwnToolsCheck.Width := RecheckButton.Left - ScaleX(8);
  OwnToolsCheck.Top := RecheckButton.Top + (RecheckButton.Height - OwnToolsCheck.Height) div 2;
  OwnToolsCheck.Checked := GetPreviousData('OwnTools', '0') = '1';

  LayoutRequirementsPage();
end;

procedure CreateAdvancedPage(AfterID: Integer);
begin
  AdvancedPage := CreateInputDirPage(AfterID,
    CustomMessage('AdvancedCaption'), CustomMessage('AdvancedDescription'), CustomMessage('AdvancedSubCaption'),
    False, SetupMessage(msgNewFolderName));
  AdvancedPage.Add(CustomMessage('QtDir'));
  AdvancedPage.Add(CustomMessage('VulkanSdk'));
  AdvancedPage.Values[0] := GetPreviousData('QtDir', '');
  AdvancedPage.Values[1] := GetPreviousData('VulkanSdk', '');
end;

function CheckAdvancedPage(): Boolean;
var
  QtDir, VulkanSdk: String;
begin
  Result := True;
  QtDir := Trim(AdvancedPage.Values[0]);
  VulkanSdk := Trim(AdvancedPage.Values[1]);
  if QtDir <> '' then
    Result := CheckFolder(QtDir, CustomMessage('QtDir')) and
      HasExpectedFile(QtDir, 'lib\cmake\Qt6\Qt6Config.cmake', CustomMessage('QtDir')) and
      HasExpectedFile(QtDir, 'lib\cmake\Qt6Charts\Qt6ChartsConfig.cmake', CustomMessage('QtDir')) and
      HasExpectedFile(QtDir, 'bin\windeployqt.exe', CustomMessage('QtDir'));
  if Result and (VulkanSdk <> '') then
    Result := CheckFolder(VulkanSdk, CustomMessage('VulkanSdk')) and
      HasExpectedFile(VulkanSdk, 'Bin\glslangValidator.exe', CustomMessage('VulkanSdk'));
end;

function SaveBuildConfig(const ConfigPath: String): Boolean;
var
  Lines: TArrayOfString;
  InstallValue, LanguageValue: String;
begin
  if InstallMissingTools() then
    InstallValue := 'true'
  else
    InstallValue := 'false';
  if IsFrench() then
    LanguageValue := 'fr'
  else
    LanguageValue := 'en';
  SetArrayLength(Lines, 12);
  Lines[0] := '{';
  Lines[1] := '  "schemaVersion": 1,';
  Lines[2] := '  "RepositoryUrl": "' + JsonEscape(Trim(RepoPage.Values[0])) + '",';
  Lines[3] := '  "GitRef": "' + JsonEscape(GetGitRef()) + '",';
  Lines[4] := '  "GitRefKind": "' + JsonEscape(GetGitRefKind()) + '",';
  Lines[5] := '  "QtDir": "' + JsonEscape(GetOwnQtDir()) + '",';
  Lines[6] := '  "VulkanSdk": "' + JsonEscape(GetOwnVulkanSdk()) + '",';
  Lines[7] := '  "Workspace": "' + JsonEscape(GetWorkspace()) + '",';
  Lines[8] := '  "SteamAppId": "' + JsonEscape(Trim(AppIdPage.Values[0])) + '",';
  Lines[9] := '  "InstallMissing": ' + InstallValue + ',';
  Lines[10] := '  "Language": "' + LanguageValue + '"';
  Lines[11] := '}';
  Result := SaveStringsToUTF8File(ConfigPath, Lines, False);
end;

// ---------------------------------------------------------------------------------------------
// "Building Eglantine" page: runs the build script hidden and shows its progress here.

function SetTimer(hWnd: HWND; nIDEvent: UINT_PTR; uElapse: UINT; lpTimerFunc: NativeInt): UINT_PTR;
external 'SetTimer@user32.dll stdcall';
function KillTimer(hWnd: HWND; nIDEvent: UINT_PTR): BOOL;
external 'KillTimer@user32.dll stdcall';
function GetTickCount(): DWORD;
external 'GetTickCount@kernel32.dll stdcall';
function OpenProcess(dwDesiredAccess: DWORD; bInheritHandle: BOOL; dwProcessId: DWORD): NativeInt;
external 'OpenProcess@kernel32.dll stdcall';
function GetExitCodeProcess(hProcess: NativeInt; var lpExitCode: DWORD): BOOL;
external 'GetExitCodeProcess@kernel32.dll stdcall';
function CloseHandle(hObject: NativeInt): BOOL;
external 'CloseHandle@kernel32.dll stdcall';

const
  ProcessQueryLimitedInformation = $1000;
  StillActive = 259;
  WmVScroll = $0115;
  SbBottom = 7;
  BuildStartTimeout = 120000;

function IsProcessAlive(Pid: DWORD): Boolean;
var
  Handle: NativeInt;
  ExitCode: DWORD;
begin
  Result := False;
  Handle := OpenProcess(ProcessQueryLimitedInformation, False, Pid);
  if Handle = 0 then
    Exit;
  if GetExitCodeProcess(Handle, ExitCode) then
    Result := ExitCode = StillActive;
  CloseHandle(Handle);
end;

function FormatElapsed(Milliseconds: DWORD): String;
var
  Seconds: Integer;
begin
  Seconds := Milliseconds div 1000;
  Result := Format('%d:%.2d:%.2d', [Seconds div 3600, (Seconds div 60) mod 60, Seconds mod 60]);
end;

procedure StopBuildTimer();
begin
  if BuildTimer <> 0 then
  begin
    KillTimer(0, BuildTimer);
    BuildTimer := 0;
  end;
end;

procedure FinishBuild(const State, ResultText: String);
begin
  StopBuildTimer();
  BuildState := State;
  BuildResult := ResultText;
  BuildStopButton.Visible := False;
  BuildElapsedLabel.Visible := False;
  BuildResultLabel.Visible := True;
  if State = 'done' then
  begin
    BuildProgress.Position := BuildProgress.Max;
    BuildResultLabel.Caption := CustomMessage('BuildDone');
    BuildResultLabel.Font.Color := $00007F00;
    BuildOpenFolderButton.Visible := True;
  end else
  begin
    BuildProgress.State := npbsError;
    if State = 'stopped' then
      BuildResultLabel.Caption := CustomMessage('BuildStopped')
    else
      BuildResultLabel.Caption := FmtMessage(CustomMessage('BuildFailed'), [ResultText]);
    BuildResultLabel.Font.Color := $000000C0;
  end;
  BuildOpenLogButton.Visible := BuildLogPath <> '';
  WizardForm.NextButton.Enabled := True;
end;

procedure PollBuild();
var
  Lines: TArrayOfString;
  I, Separator, Step, Total: Integer;
  Line, Key, Value, State, Title, Hint, ResultText, Tail: String;
begin
  BuildElapsedLabel.Caption := FmtMessage(CustomMessage('BuildElapsed'), [FormatElapsed(GetTickCount() - BuildStartTick)]);
  if not FileExists(BuildStatusPath) then
  begin
    if GetTickCount() - BuildStartTick > BuildStartTimeout then
      FinishBuild('failed', FmtMessage(CustomMessage('BuildNoStart'), [CustomMessage('BuildNoStatus')]));
    Exit;
  end;
  // The script may be rewriting the file right now; try again on the next tick.
  if not LoadStringsFromFile(BuildStatusPath, Lines) then
    Exit;

  State := '';
  Step := 0;
  Total := 6;
  Title := '';
  Hint := '';
  ResultText := '';
  Tail := '';
  Separator := -1;
  for I := 0 to GetArrayLength(Lines) - 1 do
  begin
    Line := Lines[I];
    if Separator >= 0 then
    begin
      if Tail <> '' then
        Tail := Tail + #13#10;
      Tail := Tail + Line;
      Continue;
    end;
    if Line = '---' then
    begin
      Separator := I;
      Continue;
    end;
    if Pos('=', Line) = 0 then
      Continue;
    Key := Copy(Line, 1, Pos('=', Line) - 1);
    Value := Copy(Line, Pos('=', Line) + 1, Length(Line));
    if Key = 'STATE' then State := Value
    else if Key = 'PID' then BuildPid := StrToIntDef(Value, 0)
    else if Key = 'STEP' then Step := StrToIntDef(Value, 0)
    else if Key = 'TOTAL' then Total := StrToIntDef(Value, 6)
    else if Key = 'TITLE' then Title := Value
    else if Key = 'HINT' then Hint := Value
    else if Key = 'RESULT' then ResultText := Value
    else if Key = 'LOG' then BuildLogPath := Value;
  end;
  // A half-written file has no separator yet.
  if Separator < 0 then
    Exit;

  BuildStopButton.Enabled := BuildPid > 0;
  if Step > 0 then
  begin
    BuildStepLabel.Caption := FmtMessage(CustomMessage('BuildStep'), [IntToStr(Step), IntToStr(Total), Title]);
    BuildHintLabel.Caption := Hint;
    BuildProgress.Max := Total;
    BuildProgress.Position := Step - 1;
  end;
  if Tail <> BuildLastTail then
  begin
    BuildLastTail := Tail;
    BuildMemo.Text := Tail;
    SendMessage(BuildMemo.Handle, WmVScroll, SbBottom, 0);
  end;

  if State = 'done' then
    FinishBuild('done', ResultText)
  else if State = 'failed' then
    FinishBuild('failed', ResultText)
  else if (BuildPid > 0) and not IsProcessAlive(BuildPid) then
    FinishBuild('failed', CustomMessage('BuildVanished'));
end;

procedure BuildTimerProc(Arg1: HWND; Arg2: UINT; Arg3: UINT_PTR; Arg4: DWORD);
begin
  if BuildState = 'running' then
    PollBuild();
end;

procedure StartBuild();
var
  ResultCode: Integer;
  Params: String;
begin
  BuildStatusPath := ExpandConstant('{app}\build-status.txt');
  DeleteFile(BuildStatusPath);
  BuildPid := 0;
  BuildLogPath := '';
  BuildLastTail := '';
  BuildStepLabel.Caption := CustomMessage('BuildStarting');
  Params := '-NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' +
    ExpandConstant('{app}\Build-SteamRemotePlay.ps1') + '" -ConfigPath "' +
    ExpandConstant('{app}\BuildConfig.json') + '" -StatusPath "' + BuildStatusPath + '"';
  if Exec(ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe'), Params,
       ExpandConstant('{app}'), SW_HIDE, ewNoWait, ResultCode) then
  begin
    BuildState := 'running';
    BuildStartTick := GetTickCount();
    WizardForm.NextButton.Enabled := False;
    BuildTimer := SetTimer(0, 0, 1000, CreateCallback(@BuildTimerProc));
  end else
    FinishBuild('failed', FmtMessage(CustomMessage('BuildNoStart'), [SysErrorMessage(ResultCode)]));
end;

procedure BuildStopClick(Sender: TObject);
var
  ResultCode: Integer;
begin
  if BuildState <> 'running' then
    Exit;
  if MsgBox(CustomMessage('BuildStopConfirm'), mbConfirmation, MB_YESNO) <> IDYES then
    Exit;
  if BuildPid > 0 then
    Exec(ExpandConstant('{sys}\taskkill.exe'), '/PID ' + IntToStr(BuildPid) + ' /T /F', '',
      SW_HIDE, ewWaitUntilTerminated, ResultCode);
  FinishBuild('stopped', CustomMessage('BuildStopped'));
end;

procedure BuildOpenFolderClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExec('open', BuildResult, '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

procedure BuildOpenLogClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExec('open', BuildLogPath, '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

procedure CreateBuildPage();
begin
  BuildPage := CreateCustomPage(wpInfoAfter, CustomMessage('BuildCaption'), CustomMessage('BuildDescription'));

  BuildStepLabel := TNewStaticText.Create(BuildPage);
  BuildStepLabel.Parent := BuildPage.Surface;
  BuildStepLabel.AutoSize := False;
  BuildStepLabel.Width := BuildPage.SurfaceWidth;
  BuildStepLabel.Height := ScaleY(16);
  BuildStepLabel.Font.Style := [fsBold];
  BuildStepLabel.Caption := '';

  BuildHintLabel := TNewStaticText.Create(BuildPage);
  BuildHintLabel.Parent := BuildPage.Surface;
  BuildHintLabel.AutoSize := False;
  BuildHintLabel.WordWrap := True;
  BuildHintLabel.Top := ScaleY(18);
  BuildHintLabel.Width := BuildPage.SurfaceWidth;
  BuildHintLabel.Height := ScaleY(28);
  BuildHintLabel.Caption := '';

  BuildProgress := TNewProgressBar.Create(BuildPage);
  BuildProgress.Parent := BuildPage.Surface;
  BuildProgress.Top := ScaleY(48);
  BuildProgress.Width := BuildPage.SurfaceWidth;
  BuildProgress.Height := ScaleY(14);
  BuildProgress.Min := 0;
  BuildProgress.Max := 6;
  BuildProgress.Position := 0;

  BuildElapsedLabel := TNewStaticText.Create(BuildPage);
  BuildElapsedLabel.Parent := BuildPage.Surface;
  BuildElapsedLabel.Top := ScaleY(66);
  BuildElapsedLabel.Caption := '';

  BuildResultLabel := TNewStaticText.Create(BuildPage);
  BuildResultLabel.Parent := BuildPage.Surface;
  BuildResultLabel.AutoSize := False;
  BuildResultLabel.WordWrap := True;
  BuildResultLabel.Top := ScaleY(66);
  BuildResultLabel.Width := BuildPage.SurfaceWidth;
  BuildResultLabel.Height := ScaleY(30);
  BuildResultLabel.Font.Style := [fsBold];
  BuildResultLabel.Visible := False;

  BuildStopButton := TNewButton.Create(BuildPage);
  BuildStopButton.Parent := BuildPage.Surface;
  BuildStopButton.Caption := CustomMessage('BuildStop');
  BuildStopButton.Width := ScaleX(150);
  BuildStopButton.Height := ScaleY(23);
  BuildStopButton.Left := BuildPage.SurfaceWidth - BuildStopButton.Width;
  BuildStopButton.Top := BuildPage.SurfaceHeight - BuildStopButton.Height;
  BuildStopButton.Enabled := False;
  BuildStopButton.OnClick := @BuildStopClick;

  BuildOpenFolderButton := TNewButton.Create(BuildPage);
  BuildOpenFolderButton.Parent := BuildPage.Surface;
  BuildOpenFolderButton.Caption := CustomMessage('BuildOpenFolder');
  BuildOpenFolderButton.Width := ScaleX(200);
  BuildOpenFolderButton.Height := BuildStopButton.Height;
  BuildOpenFolderButton.Top := BuildStopButton.Top;
  BuildOpenFolderButton.Visible := False;
  BuildOpenFolderButton.OnClick := @BuildOpenFolderClick;

  BuildOpenLogButton := TNewButton.Create(BuildPage);
  BuildOpenLogButton.Parent := BuildPage.Surface;
  BuildOpenLogButton.Caption := CustomMessage('BuildOpenLog');
  BuildOpenLogButton.Width := ScaleX(140);
  BuildOpenLogButton.Height := BuildStopButton.Height;
  BuildOpenLogButton.Top := BuildStopButton.Top;
  BuildOpenLogButton.Left := BuildPage.SurfaceWidth - BuildOpenLogButton.Width;
  BuildOpenLogButton.Visible := False;
  BuildOpenLogButton.OnClick := @BuildOpenLogClick;

  BuildMemo := TNewMemo.Create(BuildPage);
  BuildMemo.Parent := BuildPage.Surface;
  BuildMemo.Top := ScaleY(100);
  BuildMemo.Width := BuildPage.SurfaceWidth;
  BuildMemo.Height := BuildStopButton.Top - BuildMemo.Top - ScaleY(6);
  BuildMemo.ReadOnly := True;
  BuildMemo.ScrollBars := ssVertical;
  BuildMemo.Font.Name := 'Consolas';
  BuildMemo.Font.Size := 8;
end;

procedure InitializeWizard;
begin
  RepoPage := CreateInputQueryPage(wpWelcome,
    CustomMessage('RepoCaption'), CustomMessage('RepoDescription'), CustomMessage('RepoSubCaption'));
  RepoPage.Add(CustomMessage('RepositoryUrl'), False);
  RepoPage.Add(CustomMessage('GitRef'), False);
  RepoPage.Values[0] := GetPreviousData('RepositoryUrl', 'https://github.com/Eglantine-Community/Eglantine.git');
  RepoPage.Edits[0].OnChange := @RepoUrlChange;
  RepoPage.Edits[0].OnExit := @RepoUrlExit;
  PreviousRefKind := GetPreviousData('GitRefKind', 'branch');

  // Replace the free-text reference field with a Branch / Release tag choice and a list of
  // the repository's names of that kind.
  RepoPage.Edits[1].Visible := False;

  BranchRadio := TNewRadioButton.Create(RepoPage);
  BranchRadio.Parent := RepoPage.Surface;
  BranchRadio.Caption := CustomMessage('RefKindBranch');
  BranchRadio.Left := RepoPage.Edits[1].Left;
  BranchRadio.Top := RepoPage.Edits[1].Top;
  BranchRadio.Width := ScaleX(140);
  BranchRadio.Height := ScaleY(17);
  BranchRadio.Checked := PreviousRefKind <> 'tag';
  BranchRadio.Enabled := False;
  BranchRadio.OnClick := @RefKindClick;

  TagRadio := TNewRadioButton.Create(RepoPage);
  TagRadio.Parent := RepoPage.Surface;
  TagRadio.Caption := CustomMessage('RefKindTag');
  TagRadio.Left := BranchRadio.Left + BranchRadio.Width + ScaleX(12);
  TagRadio.Top := BranchRadio.Top;
  TagRadio.Width := ScaleX(160);
  TagRadio.Height := BranchRadio.Height;
  TagRadio.Checked := PreviousRefKind = 'tag';
  TagRadio.Enabled := False;
  TagRadio.OnClick := @RefKindClick;

  RefreshRefsButton := TNewButton.Create(RepoPage);
  RefreshRefsButton.Parent := RepoPage.Surface;
  RefreshRefsButton.Caption := CustomMessage('RefreshRefs');
  RefreshRefsButton.Width := ScaleX(90);
  RefreshRefsButton.Left := RepoPage.Edits[1].Left + RepoPage.Edits[1].Width - RefreshRefsButton.Width;
  RefreshRefsButton.OnClick := @RefreshRefsButtonClick;

  RefCombo := TNewComboBox.Create(RepoPage);
  RefCombo.Parent := RepoPage.Surface;
  RefCombo.Style := csDropDown;
  RefCombo.DropDownCount := 16;
  RefCombo.Left := RepoPage.Edits[1].Left;
  RefCombo.Top := BranchRadio.Top + BranchRadio.Height + ScaleY(6);
  RefCombo.Width := RefreshRefsButton.Left - RefCombo.Left - ScaleX(8);
  RefCombo.Text := GetPreviousData('GitRef', 'nx2');
  RefCombo.OnChange := @RefComboChange;
  RepoPage.PromptLabels[1].FocusControl := RefCombo;

  RefreshRefsButton.Top := RefCombo.Top - ScaleY(1);
  RefreshRefsButton.Height := RefCombo.Height + ScaleY(2);

  RefStatusText := TNewStaticText.Create(RepoPage);
  RefStatusText.Parent := RepoPage.Surface;
  RefStatusText.AutoSize := False;
  RefStatusText.WordWrap := True;
  RefStatusText.Left := RefCombo.Left;
  RefStatusText.Top := RefCombo.Top + RefCombo.Height + ScaleY(8);
  RefStatusText.Width := RepoPage.Edits[1].Width;
  RefStatusText.Height := ScaleY(40);
  RefStatusText.Caption := '';

  CreateRequirementsPage(RepoPage.ID);
  CreateAdvancedPage(ReqPage.ID);

  AppIdPage := CreateInputQueryPage(AdvancedPage.ID,
    CustomMessage('AppIdCaption'), CustomMessage('AppIdDescription'), CustomMessage('AppIdSubCaption'));
  AppIdPage.Add(CustomMessage('AppId'), False);
  AppIdPage.Values[0] := GetPreviousData('SteamAppId', '');

  ConsentPage := CreateInputOptionPage(AppIdPage.ID,
    CustomMessage('ConsentCaption'), CustomMessage('ConsentDescription'), CustomMessage('ConsentSubCaption'),
    False, False);
  ConsentPage.Add(CustomMessage('ConsentTrust'));
  ConsentPage.Add(CustomMessage('ConsentAppId'));
  ConsentPage.Add(CustomMessage('StartBuild'));
  ConsentPage.Values[2] := True;

  CreateBuildPage();
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
  SetPreviousData(PreviousDataKey, 'RepositoryUrl', Trim(RepoPage.Values[0]));
  SetPreviousData(PreviousDataKey, 'GitRef', GetGitRef());
  if GetGitRefKind() <> '' then
    SetPreviousData(PreviousDataKey, 'GitRefKind', GetGitRefKind())
  else
    SetPreviousData(PreviousDataKey, 'GitRefKind', PreviousRefKind);
  SetPreviousData(PreviousDataKey, 'QtDir', Trim(AdvancedPage.Values[0]));
  SetPreviousData(PreviousDataKey, 'VulkanSdk', Trim(AdvancedPage.Values[1]));
  if OwnToolsCheck.Checked then
    SetPreviousData(PreviousDataKey, 'OwnTools', '1')
  else
    SetPreviousData(PreviousDataKey, 'OwnTools', '0');
  SetPreviousData(PreviousDataKey, 'Workspace', GetWorkspace());
  SetPreviousData(PreviousDataKey, 'SteamAppId', Trim(AppIdPage.Values[0]));
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if WizardSilent then
    Exit;
  if CurPageID = RepoPage.ID then
    LoadGitRefs(False)
  else if CurPageID = ReqPage.ID then
  begin
    if (not ReqDone) or (GetWorkspace() <> ReqCheckedWorkspace) then
      RunRequirementCheck();
  end else if CurPageID = BuildPage.ID then
  begin
    if BuildState = '' then
      StartBuild()
    else
      WizardForm.NextButton.Enabled := BuildState <> 'running';
  end else if CurPageID = wpFinished then
  begin
    if BuildState = 'done' then
      WizardForm.FinishedLabel.Caption := FmtMessage(CustomMessage('FinishedDone'), [BuildResult])
    else if (BuildState = 'failed') or (BuildState = 'stopped') then
      WizardForm.FinishedLabel.Caption := FmtMessage(CustomMessage('FinishedFailed'), [BuildResult, BuildLogPath]);
    WizardForm.FinishedLabel.AdjustHeight();
  end;
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  if BuildState = 'running' then
  begin
    MsgBox(CustomMessage('BuildStillRunning'), mbInformation, MB_OK);
    Cancel := False;
  end;
end;

procedure DeinitializeSetup();
begin
  StopBuildTimer();
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  // Silent installation is only for deployment/testing of the builder itself. It never starts a
  // build and it has no answers for custom pages, so retain their defaults in BuildConfig.json.
  Result := WizardSilent and ((PageID = RepoPage.ID) or (PageID = ReqPage.ID) or
    (PageID = AdvancedPage.ID) or (PageID = AppIdPage.ID) or (PageID = ConsentPage.ID));
  if (PageID = AdvancedPage.ID) and not OwnToolsCheck.Checked then
    Result := True;
  if (PageID = BuildPage.ID) and (WizardSilent or not ConsentPage.Values[2] or not ConfigSaved) then
    Result := True;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = RepoPage.ID then
  begin
    if not IsGitHubRepositoryUrl(RepoPage.Values[0]) then
    begin
      MsgBox(CustomMessage('InvalidRepository'), mbError, MB_OK);
      Result := False;
    end else if GetGitRef() = '' then
    begin
      MsgBox(CustomMessage('RefsNotChosen'), mbError, MB_OK);
      Result := False;
    end else if not IsSafeRef(GetGitRef()) then
    begin
      MsgBox(CustomMessage('InvalidRef'), mbError, MB_OK);
      Result := False;
    end;
  end else if CurPageID = ReqPage.ID then
    Result := CheckRequirementsPage()
  else if CurPageID = AdvancedPage.ID then
    Result := CheckAdvancedPage()
  else if CurPageID = AppIdPage.ID then
  begin
    if not IsPositiveNumber(Trim(AppIdPage.Values[0])) then
    begin
      MsgBox(CustomMessage('InvalidAppId'), mbError, MB_OK);
      Result := False;
    end;
  end else if CurPageID = ConsentPage.ID then
  begin
    if not ConsentPage.Values[0] or not ConsentPage.Values[1] then
    begin
      MsgBox(CustomMessage('ConsentNeeded'), mbError, MB_OK);
      Result := False;
    end;
  end;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo,
  MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var
  Reference, QtText, VulkanText: String;
begin
  Reference := GetGitRef();
  if GetGitRefKind() = 'tag' then
    Reference := Reference + ' (' + CustomMessage('RefKindTagShort') + ')'
  else if GetGitRefKind() = 'branch' then
    Reference := Reference + ' (' + CustomMessage('RefKindBranchShort') + ')';
  QtText := GetOwnQtDir();
  if QtText = '' then
    QtText := 'Qt 6.8.3, ' + CustomMessage('Automatic');
  VulkanText := GetOwnVulkanSdk();
  if VulkanText = '' then
    VulkanText := 'glslang, ' + CustomMessage('Automatic');
  Result := CustomMessage('ReviewRepository') + NewLine + Space + Trim(RepoPage.Values[0]) + NewLine +
    CustomMessage('ReviewReference') + NewLine + Space + Reference + NewLine +
    CustomMessage('ReviewQt') + NewLine + Space + QtText + NewLine +
    CustomMessage('ReviewVulkan') + NewLine + Space + VulkanText + NewLine +
    CustomMessage('ReviewWorkspace') + NewLine + Space + GetWorkspace() + NewLine +
    CustomMessage('ReviewAppId') + NewLine + Space + Trim(AppIdPage.Values[0]) + NewLine;
  if InstallMissingTools() then
    Result := Result + CustomMessage('ReviewInstallVs') + NewLine + Space + CustomMessage('Yes') + NewLine;
  Result := Result + NewLine +
    CustomMessage('ReviewInstall') + NewLine + Space + ExpandConstant('{app}') + NewLine + NewLine +
    CustomMessage('ReviewSafe');
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ConfigPath: String;
begin
  if CurStep <> ssPostInstall then
    Exit;
  ConfigPath := ExpandConstant('{app}\BuildConfig.json');
  // The "Building Eglantine" page that follows starts the build from this file.
  ConfigSaved := SaveBuildConfig(ConfigPath);
  if not ConfigSaved then
    MsgBox('Could not save ' + ConfigPath + '.', mbError, MB_OK);
end;
