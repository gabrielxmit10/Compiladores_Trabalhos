%{
// cd "/mnt/c/Users/55219/Documents/UFRJ/6° Período/Compiladores/Trab1_lex"
// Código em c/c++
// ./a.out < input.txt

#include <iostream>

string lexema;

bool in_string2 = false;

%}

/* Coloque aqui definições regulares */

WS  [ \t\n\r]

D   [0-9]

INT     {D}+

FLOAT   {INT}((\.{INT})([Ee]([\+\-])?{INT})?|[Ee]([\+\-])?{INT})
/* caso 1e3 ou (caso 1.2 (com e3 zero ou uma vez)) */

FOR     [Ff][Oo][Rr]

IF      [Ii][Ff]

MAIG    ">="

MEIG    "<="

IG      "=="

DIF     "!="

ABRE_COMENTARIO  "/*"

FECHA_COMENTARIO  "*/"

ABRE_COMENTARIO_2_BARRAS    "//"

STRING_2ASPAS_PARTE_1_OU_MAIS      \"[^"]*(\\|\")

STRING_2ASPAS_PARTE_FINAL      \"[^"]*\"

STRING_1ASPAS_PARTE_1_OU_MAIS       \'[^']*(\\|\')

STRING_1ASPAS_PARTE_FINAL      \'[^']*\'

STRING2_COM_SIFRAO     `([^$]|\$[^{])*\$\{{ID}\}[^`]*`

STRING2_GERAL       `[^`]*`

ID  [A-Za-z_$][A-Za-z_0-9$]*





/* ----------------------------------------------------------------------------- */

%%
    /* Padrões e ações. Nesta seção, comentários devem ter um tab antes */
    /*gdfefefefefef efefefefeok    iii23423ab */
    /*gdfefefefefef efefefefeok    iii23423 */
    /*{ABRE_COMENTARIO}[^a/b]*ab    { lexema = yytext; return _COMENTARIO; }*/
    /* a = "; b = \ ; c = ' */

{ABRE_COMENTARIO_2_BARRAS}[^\n]*    { lexema = yytext; return _COMENTARIO; }

{ABRE_COMENTARIO}([^*]|\*[^/])*{FECHA_COMENTARIO}    { lexema = yytext; return _COMENTARIO; }

{STRING_2ASPAS_PARTE_1_OU_MAIS}/\"     { // caso de \" ou ""
    
    if (lexema[0] == '\"'){
        lexema += yytext;
    }
    else {lexema = yytext;}

    lexema.erase(lexema.size() - 1, 1); // removendo a \ ou " pra ficar só "
    
    }

{STRING_2ASPAS_PARTE_FINAL}    { // caso de string" completa ou o fim de uma com " no meio
    
    if (lexema[0] == '\"'){
        lexema += yytext;
    }
    else {
        lexema = yytext;
    }
    
    lexema = lexema.substr(1, lexema.size() - 2); // tirando " do começo e " do fim da string
    return _STRING; }

{STRING_1ASPAS_PARTE_1_OU_MAIS}/\'     { // caso de \' ou ''
    
    if (lexema[0] == '\''){
        lexema += yytext;
    }
    else {lexema = yytext;}

    lexema.erase(lexema.size() - 1, 1); // removendo a \ ou ' pra ficar só '
    
    }

{STRING_1ASPAS_PARTE_FINAL}    { // caso de string' completa ou o fim de uma com ' no meio
    
    if (lexema[0] == '\''){
        lexema += yytext;
    }
    else {
        lexema = yytext;
    }
    
    lexema = lexema.substr(1, lexema.size() - 2); // tirando ' do começo e ' do fim da string
    return _STRING; }

{STRING2_COM_SIFRAO}      {

    lexema = yytext;

    size_t sifrao_posicao = -1;
    size_t fecha_chave_posicao = -1;

    for ( size_t i = 0 ; i < lexema.size() ; i++ ){ // achando sifrao_posicao
        if ((lexema[i] == '$') && (lexema[i+1] == '{')){
            sifrao_posicao = i;
            break;
        }
    }

    for ( size_t i = sifrao_posicao ; i < lexema.size() ; i++ ){ // achando fecha_chave_posicao
        if (lexema[i] == '}'){
            fecha_chave_posicao = i;
            break;
        }
    }

    string string2_parte1 = lexema.substr(1, sifrao_posicao - 1);
    printf( "%d %s\n", _STRING2, string2_parte1.c_str() ); // primeira parte da string2

    string string2_expr = lexema.substr(sifrao_posicao + 2, fecha_chave_posicao - (sifrao_posicao + 2));
    printf( "%d %s\n", _EXPR, string2_expr.c_str() ); // parte da expr da string2
    
    lexema = lexema.erase(0, fecha_chave_posicao + 1); // ultima parte da string2
    lexema.pop_back(); // tirando ` do final
    return _STRING2;
    }

{STRING2_GERAL}     { 
    lexema = yytext; 
    lexema = lexema.substr(1, lexema.size() - 2); // tirando ` do inicio e `do fim
    return _STRING2; }



{WS}	{ /* ignora espaços, tabs e '\n' */ } 

{FOR}   { lexema = yytext; return _FOR; }

{IF}   { lexema = yytext; return _IF; }

{FLOAT}    { lexema = yytext; return _FLOAT; }

{INT}   { lexema = yytext; return _INT; }

{MAIG}   { lexema = yytext; return _MAIG; }

{MEIG}   { lexema = yytext; return _MEIG; }

{DIF}   { lexema = yytext; return _DIF; }

{IG}   { lexema = yytext; return _IG; }

{ID}    { 
    
    lexema = yytext;
    string lexema_dps_do_primeiro_char = lexema.substr(1, lexema.size() - 1);

    if (lexema_dps_do_primeiro_char.find('$') != string::npos){ // caso de $ dps da posicao 1
        string msg_de_erro = "Erro: Identificador invalido: " + lexema + "\n";
        printf("%s", msg_de_erro.c_str());
    }
    else {
        return _ID;
    }
    }


.       { lexema = yytext; return *yytext; 
          /* Essa deve ser a última regra. Dessa forma qualquer caractere isolado será retornado pelo seu código ascii. */ }

    /* ------------------------------------------------------------------------------ */

%%

/* Não coloque nada aqui - a função main é automaticamente incluída na hora de avaliar e dar a nota. */
