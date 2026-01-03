# Contexte global : qu’est-ce que c’est que ce fichier ?

C’est un **boot sector** (secteur d’amorçage) minimal en **assembleur x86 16-bit**.

Quand un PC “classique BIOS” démarre :

1. Le BIOS cherche un périphérique bootable (disque, clé USB…)
2. Il **lit le tout premier secteur** (512 octets) du périphérique (LBA 0)
3. Il copie ces 512 octets en RAM à l’adresse **0x0000:0x7C00** (souvent écrite “0x7C00”)
4. Il saute à cette adresse et exécute le code en **mode réel** (real mode, 16-bit)

Ce code permet d'afficher P.O.S à l’écran via le BIOS, puis boucle infinie.

# Notions de base indispensables

## 1. Mode réel (16-bit)

Au tout début, on est en **real mode** :

- registres **16 bits** (AX, BX, CX, DX, SP, BP, SI, DI)
- adressage mémoire via **segment:offset**
    - adresse physique = `segment * 16 + offset`
    - ex : `0x0000:0x7C00` → `0x0000 * 16 + 0x7C00 = 0x7C00`

## 2. Registres AH / AL et AX

Dans x86 :

- `AX` est un registre 16-bit
- il est découpé en deux registres 8-bit :
    - `AH` = octet haut (bits 15..8)
    - `AL` = octet bas (bits 7..0)

Donc :

- `mov ah, 0x0e` met 0x0E dans AH
- `mov al, 'P'` met le code ASCII de P dans AL

Et AX vaut alors 0x0E?? (où ?? dépend de AL).

## 3. Interruptions BIOS (int 0x10)

En mode réel, on peut appeler des services BIOS via `int xx`.

`int 0x10` = **services vidéo BIOS**.

Et `AH=0x0E` sélectionne la fonction **teletype output** :

- affiche le caractère dans `AL`
- avance le curseur
- gère scrolling, etc.

Donc le couple :

- `mov ah, 0x0e`
- `mov al, 'X'`
- `int 0x10`

=> affiche X.