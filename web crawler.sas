%macro xxx; 
%do i =  1 %to 7243 ; 	 /*7243*/
filename in_&i "d:\pachong\in_&i..txt" ;
filename out_&i "d:\pachong\out_&i..txt" ;
proc http out=in_&i  URL="http://so.gushiwen.org/type.aspx?p=&i"  ;
run;

data _null_ ;
length text pose pose1 pose2 $32767 ; 
 infile in_&i truncover length=len ;
 file out_&i dlm='~' ;
 input text $varying32767. len;
 retain pose2 ; 
 if find(text , '<textarea') =1  then do ;
  call missing(pose2) ; 
	 pose= tranwrd(text, 'ttp','>') ;  /* dan teng */
	 pose1=  scan(pose,2,'>') ;
	 pose2=  substr(pose1, 1, length(pose1)-1) ;
 end;

 if find(text , 'alt="赞"') >0 then do ;
    score=  cats(compress(substr(text, find(text, '<span>&nbsp;' ) +10 ) ,,'ap'));  
 end; 
if pose2 ne '' and score ne '' then  put pose2   score;
run;
%end; 
%mend;

%xxx
 
%let output = D:\ ;
libname out "&output";
%let dirname = d:\pachong;
filename dirlist pipe "dir /B &dirname\out*.txt";

data dirlist ;
     length fname $256; 
     infile dirlist length=reclen  ;
     input fname $varying256. reclen ;
run;

proc sort data= dirlist SORTSEQ =LINGUISTIC (NUMERIC_COLLATION=ON); 
  by fname;
run;


data out.all_text ;
 length dat $500 dynasty $100 author $100 title $200 content $9999 text $32767. score 8.;
  set dirlist    /* (obs=6398 firstobs=6398)  */ ;
  filepath = "&dirname\"||fname;

  infile dummy filevar = filepath length=reclen end=done truncover ;
  do while (not done);
    myfilename = filepath;
   input  text $ &  ; 
    dat = kscan(text,-1,'——'); 
	dynasty =  kscan(dat,1,'·《》~'); 
	author =  kscan(dat,2,'·《》~'); 
	title = kscan(dat,3,'·《》~'); 
	content = ksubstr(text,1, KINDEX(text,dat)-3  ); 
	score = input(kscan(dat,-1,'·《》~'),best.); 
    if title ne '' and content ne '' then output;
  end;

  keep   dynasty   author   title   content   text   score  ;
run;



