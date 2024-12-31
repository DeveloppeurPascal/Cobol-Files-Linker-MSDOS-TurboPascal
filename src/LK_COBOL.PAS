Program Lk_Cobol;            { mise … jour : 19 - 01 - 1991 }

{
Titre : Editeur de liens entre fichiers COBOL.

Auteur: Pr‚martin Patrick.
Date de la premiŠre version: 31 d‚cembre 1990.


Cet utilitaire permet de palier au problŠme de 'Editeur de sources en Cobol'
qui ne peut prendre des fichiers de plus de 900 lignes.

Afin de r‚gler le problŠme, il suffit de cr‚er un listing comme indiqu‚ ici:
                                                                       7
      7A   B                                                           2

  ex: *$ progname nom_prog.cbl

      *$ include  fichier1.cbl
      *$ include  c:\.CBL\fichier2.cbl
      *$ include  \prog_cbl\fichier3.cbl
            .
            .
            .
      *$ include:  fichierX.cbl

Ce listing aura pour effet  de cr‚er un fichier 'nom_prog.cbl' (nom qui suit
la commande PROGNAME)  compilable qui  contiendra dans  l'ordre les fichiers
'fichier1.cbl' ... 'fichierX.cbl' … la place de la commande INCLUDE.

Il faut en colonne 7 la chaine '*$' pour indiquer … ce programme qu'il doit
prendre en consid‚ration une instruction de linkage.
}

Uses Crt,
     olf_software,
     u_Sgf,
     u_aff_Chaine,
     u_Fenetre;

Const
     Date_Version : String [10] = '19-01-1991';
      Num_Version  : String [3]  = '1.1';

Var Sortie : Boolean;

Procedure Attente_Appuit_Touche;
Var Carac        : Char;
    Old_Textattr : Integer;
Begin { attente_appuit_touche }
  Old_Textattr := Textattr;
  Textcolor (White);
  Textbackground (Black);
  Affic_Center ('Appuyez sur une touche...');
  While (Keypressed) Do Carac := Readkey;
  Carac := Readkey;
  Textattr := Old_Textattr;
  Gotoxy (1, Wherey);
  Clreol
End; { attente_appuit_touche }

Procedure Presentation;
Begin { presentation }
  Type_Cadre := 5;
  Window_Cadre_Bis (2, 2, 79, 23, Brown, Blue);
  Window_Titre ('Editeur de liens entre fichiers COBOL.', Lightblue+Blink, Red);
  Textcolor (White);
  Textbackground (Green);
  Clrscr;
  Affic_Center_Ln ('Auteur: Pr‚martin Patrick');
  Affic_Center_Ln (Concat ('Version ', Num_Version));
  Affic_Center_Ln (Concat ('Date ', Date_Version));
  Writeln;
  Write   ('   Cet utilitaire permet de concatener  (ajouter) divers fichiers textes. Vous');
  Writeln ('pourrez linker des fichiers COBOL ou n''importe quels autres fichiers textes.');
  Writeln;
  Writeln ('   Pour utiliser ce programme, cr‚ez un fichier texte ayant cette structure:');
  Writeln;
  Writeln ('             *$ PROGNAME nom du fichier final');
  Writeln;
  Writeln ('             *$ INCLUDE   nom du premier fichier … inclure (avec extension)');
  Writeln ('                   .');
  Writeln ('                   .');
  Writeln ('                   .');
  Writeln ('             *$ INCLUDE   nom du dernier fichier … inclure (ex: FICH5.CBL)');
  Writeln;
  Writeln ('    Ce programme mettra les fichiers les uns derriŠre les autres dans l''ordre');
  Writeln (' sp‚cifi‚ dans le fichier de linkage. (vous pouvez cr‚er ce fichier avec tous');
  Writeln (' les ‚diteurs de texte que vous voudrez.');
  Writeln;
  Attente_Appuit_Touche;
  Clear_Window
End; { presentation }

Procedure Ask_Nom_Fichier (Var Nom_Fichier : String);
Var Nom_Fic : String;
Begin { ask_nom_fichier }
  Type_Cadre := 10;
  Window_Cadre_Bis (2, 2, 79, 3, Lightblue, Blue);
  Window_Titre (Concat ('Nom par d‚faut: ', Nom_Fichier), White, Red);
  Nom_Fic := '';
  Repeat
    Clrscr;
    If (Nom_Fic <> '')
    Then
      Affic_Center_Ln (Concat (Nom_Fic, ' n''existe pas.'))
    {endif};
    Readln (Nom_Fic)
  Until ((Nom_Fic = '') Or (Exist (Nom_Fic)));
  If (Nom_Fic <> '')
  Then
    Nom_Fichier := Nom_Fic
  {endif};
  Clear_Window
End; { ask_nom_fichier }

Procedure Maj_Chaine (Chaine1 : String; Var Chaine2 : String);
Var I : Integer;
Begin { maj_chaine }
  For I := 1 To Length (Chaine1) Do
    Chaine2 [I] := Upcase (Chaine1 [I])
  {endfor};
  Chaine2 [0] := Chaine1 [0]
End; { maj_chaine }

Procedure Message_Alerte (Message : String; Waiting : Boolean);
Begin { message_alerte }
  Clear_Window;
  Type_Cadre := 4;
  Window_Cadre_Bis (2, 2, 79, 2, Red, Blue);
  Window_Titre (Message, White, Blue);
  Clrscr;
  If (Waiting)
  Then
    Begin
      Attente_Appuit_Touche;
      Clear_Window
    End
  {endif}
End; { message_alerte }

Procedure Traite_Ligne (Message : String; Var Chaine : String; I : Integer; Var Fichier : Text);
Begin { traite_ligne }
  Delete (Chaine, 1, I);
  While Not (Chaine [1] <> ' ') Do
    Delete (Chaine, 1, 1)
  {endwhile};
  I := Pos (' ', Chaine);
  If (I > 0)
  Then
    Chaine := Copy (Chaine, 1, Pred (I))
  {endif};
  Sortie := Not (Exist (Chaine));
  Assign (Fichier, Chaine);
  If Not Sortie
  Then
    Message_Alerte (Concat (Message, Chaine), False)
  {endif}
End; { traite_ligne }

Procedure Link (Var Fichier_Source, Fichier_Dest : Text);
Var Ligne : String;
Begin { link }
  If Not Sortie
  Then
    Begin
      Reset (Fichier_Source);
      While Not (Eof (Fichier_Source)) Do
        Begin
          Readln (Fichier_Source, Ligne);
          Writeln (Fichier_Dest, Ligne)
        End
      {endwhile};
      Close (Fichier_Source)
    End
  Else
    Message_Alerte ('Fatale error, ce fichier n''existe pas !', True)
  {endif}
End; { link }

Procedure Modif_Prog (Nom_Fich1 : String);
Var Chaine     : String;
    I          : Integer;
    Fichier1,              { fichier contenant les ordres de linkage }
    Fichier2,              { fichier destination                     }
    Fichier3   : Text;     { fichier en cours d'inclusion            }
Begin { modif_prog }
  If (Exist (Nom_Fich1))
  Then
    Begin
      Sortie := False;
      Message_Alerte ('Traitement en cours...', False);
      Assign (Fichier1, Nom_Fich1);
      Reset (Fichier1);
      While Not ((Eof (Fichier1)) Or (Sortie)) Do
        Begin
          Readln (Fichier1, Chaine);
          Maj_Chaine (Chaine, Chaine);
          I := Pos ('*$', Chaine);
          If (I > 0)
          Then
            Begin
              Delete (Chaine, 1, I+1);
              I := Pos ('PROGNAME', Chaine);
              If (I > 0)
              Then
                Begin
                  Traite_Ligne ('Fichier final: ', Chaine, I+7, Fichier2);
                  Rewrite (Fichier2);
                  Sortie := False
                End
              Else
                Begin
                  I := Pos ('INCLUDE', Chaine);
                  If (I > 0)
                  Then
                    Begin
                      Traite_Ligne ('Fichier … inclure: ', Chaine, I+6, Fichier3);
                      Link (Fichier3, Fichier2)
                    End
                  {endif}
                End
              {endif}
            End
          {endif}
        End
      {enwhile};
      Close (Fichier1);
      Close (Fichier2);
      Message_Alerte ('Fin de traitement...', True)
    End
  Else
    Message_Alerte ('Ce fichier n''existe pas.', True)
  {endif}
End; { modif_prog }

Function Ask_Recommencer : Boolean;
Var Carac : Char;
Begin { recommencer }
  Type_Cadre := 2;
  Window_Cadre_Bis (5, 10, 75, 10, Blue, Green);
  Window_Titre ('Voulez-vous faire un autre fichier ?', Black, Lightgray);
  Textcolor (White);
  Textbackground (Black);
  Clrscr;
  Affic_Center ('Votre choix ? (Oui / Non) ');
  Repeat
    Carac := Upcase (Readkey);
    Write (Carac);
    Gotoxy (Pred (Wherex), Wherey)
  Until (Carac In ['O', 'N']);
  Clear_Window;
  Ask_Recommencer := (Carac = 'O')
End; { ask_recommencer }

Procedure Traitement;
Var Nom_Fichier : String;
Begin { traitement }
  Nom_Fichier := 'NONAME.CBL';
  Repeat
    Ask_Nom_Fichier (Nom_Fichier);
    Modif_Prog (Nom_Fichier)
  Until Not (Ask_Recommencer)
End; { traitement }

Begin { lk_cobol }
      init_olf_message (mess_freeware);
      init_licence ('LKCO');
      init_olf_software ('Linker Cobol '+num_version, #155' Patrick Pr‚martin '+date_version);
  Reset_screen;
  Presentation;
  Traitement;
  Reset_screen
End. { lk_cobol }
