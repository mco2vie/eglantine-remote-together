Outil Eglantine Steam Remote Play
=================================

Cet outil crée une compilation Windows PRIVÉE d'Eglantine avec Steam Remote
Play Together. Il fonctionne à partir du code source du dépôt GitHub
Eglantine ou d'un fork que vous choisissez.

Il ne modifie pas une installation Eglantine existante. Il crée un nouveau
dossier de travail du code source, un dossier de compilation, un dossier de
sortie, un journal et build-manifest.json dans l'espace de compilation choisi
dans l'assistant.

Avant de compiler, installez vous-même ces éléments :

1. Visual Studio 2022 ou plus récent, avec "Développement Desktop en C++".
   https://visualstudio.microsoft.com/vs/community/

2. Qt pour MSVC 2022 64-bit, incluant Qt Charts. La version 6.8.3 a été
   testée avec ce patch ; si le fork demande une autre version, utilisez celle
   qu'il demande.
   https://www.qt.io/download-qt-installer-oss

3. Le SDK Vulkan, avec glslangValidator.exe.
   https://vulkan.lunarg.com/sdk/home#windows

4. Le SDK Steamworks 1.62 ou plus récent, obtenu avec un accès autorisé par Valve. Vous
   avez aussi besoin d'un App ID que vous possédez ou que vous êtes explicitement autorisé
   à utiliser, et qui est configuré pour Remote Play Together. Choisissez son dossier
   "sdk" dans l'assistant.
   https://partner.steamgames.com/downloads/list

L'outil vérifie ces éléments, l'URL GitHub et la branche/le tag. Il crée un
miroir Git et un dossier de travail privés, vérifie et applique le patch de
code source, puis s'arrête si le patch ne peut pas être appliqué proprement.
Il ne remplace jamais vos fichiers Eglantine normaux.

N'utilisez qu'un dépôt auquel vous faites confiance. Compiler un code source
peut exécuter les instructions CMake de ce dépôt sur votre PC.

L'outil démarre sa propre fenêtre PowerShell avec un réglage temporaire de la
politique d'exécution pour lancer le script de compilation fourni. Il ne change
pas vos réglages Windows PowerShell et n'installe aucun logiciel automatiquement.

Le résultat contient steam_api64.dll du SDK Valve. Ne partagez pas et ne
publiez pas cette compilation. L'outil lui-même ne contient aucun fichier du
SDK Steamworks.

Relancez l'outil pour compiler une autre version ou un autre fork. Il garde les
dossiers de travail et les journaux précédents pour qu'une compilation en échec
puisse être vérifiée sans perdre de données.

Une compilation réussie crée un dossier complet et un zip privé dans le
dossier output de l'espace de compilation. Il contient également README.txt,
build-manifest.json et le chemin vers le journal en cas de problème. L'App ID
saisi dans l'assistant doit être un App ID que vous possédez ou que vous êtes
autorisé à utiliser.
