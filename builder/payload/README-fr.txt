Outil Eglantine Steam Remote Play
=================================

Cet outil crée une compilation Windows PRIVÉE d'Eglantine avec Steam Remote
Play Together. Il fonctionne à partir du code source du dépôt GitHub
Eglantine ou d'un fork que vous choisissez.

Il ne modifie pas une installation Eglantine existante. Dans le dossier de
compilation choisi dans l'assistant, il garde un dossier de code source et de
compilation par dépôt (work\...), ainsi qu'un journal, un dossier de sortie et
build-manifest.json pour chaque compilation.

Ce que vous préparez vous-même
------------------------------

Un App ID Steam que vous possédez ou que vous êtes explicitement autorisé à
utiliser, et qui est configuré pour Remote Play Together. Aucun SDK Steamworks
n'est nécessaire.

Ce que l'outil récupère pour vous s'il manque
---------------------------------------------

La page « Vérification de votre PC » de l'assistant affiche ce qui est prêt.
Pendant la compilation, l'assistant récupère ce qui manque :

- Le compilateur Microsoft C++ (Visual Studio Build Tools, gratuit, environ
  8 Go), seulement si vous avez coché « Installer le compilateur Microsoft C++
  pour moi ». Il utilise l'installateur de Microsoft, vérifie la signature de
  Microsoft, et Windows vous demande une autorisation administrateur une fois.
- Git, Qt 6.8.3 avec Qt Charts, et le compilateur de shaders glslang. Ils sont
  téléchargés uniquement dans <dossier de compilation>\cache\tools, vérifiés
  avec des SHA-256 fixes, et réutilisés par les compilations suivantes.

La bibliothèque d'exécution de Steam (steam_api64.dll, SDK Steamworks 1.65)
est fournie avec l'outil, dans ce dossier : rien n'est téléchargé chez Valve.

Les utilisateurs avancés peuvent cocher « Utiliser mes propres dossiers Qt ou
SDK Vulkan » dans l'assistant.

La compilation
--------------

La page « Compilation d'Eglantine » de l'assistant affiche six étapes
numérotées, une barre de progression et le journal en direct. La première
compilation peut prendre une à deux heures, surtout pour les téléchargements
et la compilation. En cas de réussite, un bouton ouvre le dossier contenant le
nouvel eglantine.exe. En cas d'échec, le message en rouge indique
quoi corriger ; relancez ensuite l'outil, il conserve ce qui a déjà été
téléchargé.

L'outil vérifie l'URL GitHub et la branche ou le tag, crée un miroir Git et un
dossier de travail privés, vérifie et applique le patch de code source, puis
s'arrête si le patch ne peut pas être appliqué proprement. Le patch ajoute le
système d'extensions d'Eglantine et l'extension Steam Remote Play Together
(https://github.com/damienjacinto/eglantine-remote-play-together), compilée
avec Eglantine.

N'utilisez qu'un dépôt auquel vous faites confiance. Compiler un code source
peut exécuter les instructions CMake de ce dépôt sur votre PC.

L'assistant lance le script de compilation fourni dans un processus PowerShell
caché, avec un réglage temporaire de la politique d'exécution. Pour recompiler
sans l'assistant, lancez Run-Build.cmd dans ce dossier. Il ne change
pas vos réglages Windows PowerShell.

Utiliser la compilation
-----------------------

1. Démarrez Steam et connectez-vous, puis lancez eglantine.exe depuis le
   dossier de sortie.
2. La première fois, ouvrez Extensions > Manage Extensions..., cochez
   « Steam Remote Play Together », puis redémarrez Eglantine.
3. Utilisez Multiplayer > Remote Play Together: Invite Friends... ou Copy
   Guest Link. Multiplayer > Remote Play Together: Steam App ID... change
   l'App ID (pris en compte au prochain démarrage).

Le dossier extensions\dev.eglantine.remote-play-together du résultat contient
le fichier steam_api64.dll de Valve (un redistribuable Steamworks). Gardez
cette compilation pour vous.

Relancez l'outil pour compiler une autre version ou un autre fork. Les
compilations suivantes réutilisent le travail précédent : seuls les fichiers
modifiés sont recompilés, et un cache de compilation (sccache) conserve les
résultats d'une branche à l'autre. Si un outil ou un dossier a changé, l'outil
repart de lui-même sur une compilation propre. Les journaux de chaque
compilation sont conservés.
