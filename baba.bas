

;baba.prg ==0801==
    1 rem@ \constant w,h,mx,mu
    2 rem@ \integer fu,tu,ud,dx,u,ck,ds
    4 rem@ \byte n,pf%(:\word x,i
    5 rem baba is you demake by nick bensema
    6 w=10:h=11:mx=h*w-1
    7 rem@ \fastfor
   10 dim pf%(mx):rem playfield map
   11 dim dl%(mx):rem playfield deltas
   12 dim ru%(31):rem rules
   13 def fnpp(pf)=ru%(pf%(pf)and31)
   14 def fnpb(pf)=ru%(pf%(pf)and31)orru%(pf%(pf)/32)
   15 dim gr$(31):rem gfx tiles 4x1
   17 dim lv$(3):rem level data strings
   18 rem undo stack tile#,oldvalue,move#
   19 mu=300:dim ud%(mu,2)
   48 rem@ \datatype string
   49 rem objs 0-7
   51 data "{blk}....","{wht}.ZZ.","{gry3}{CBM-D}{rvon}{CBM-Y}{CBM-Y}{rvof}{CBM-F}","{orng}{rvon}{CBM-R}{CBM-E}{CBM-R}{CBM-E}{rvof}","{yel} N{CBM-U} ","{lblu}////","{yel} W{CBM-R} ","{rvon}{red}O -P{rvof}"
   52 data "{cyn}{rvon}you {rvof}"
   53 data "{cyn}{rvon}win!{rvof}"
   54 data "{cyn}{rvon}stop{rvof}"
   55 data "{cyn}{rvon}push{rvof}"
   56 data "{cyn}{rvon}shut{rvof}"
   57 data "{cyn}{rvon}open{rvof}"
   58 data "{cyn}{rvon}sink{rvof}"
   59 data "{cyn}{rvon}lose{rvof}"
   60 rem names
   61 data "{wht} is ","{wht}baba","{wht}rock","{wht}wall","{yel}flag","{lblu}watr","{yel}key ","{wht}door"
   69 rem levels. todo: better ones
   70 data " @qph@@spj  @cccccccc @eeeebe @eaeebeed @eeeebe @cccccccc  @tpi@@rpk"
   71 data " @qph@@spj  @C@@@@@c @eaefgeed @@@@@c @C@tpi@@vpk @wpl@@vpm"
   72 data " @qph@@spj  @C@@@@@e@ @@a@be@@d @@@@@e@ @C@tpi@@rpk @upn@@@@@"
   73 data " @qph@@spj  eeeeeb eeaebbeed eeeeeb @cccccccc @tpi@@rpk @p @h"
   80 for x=0to23:readgr$(x):next x
   90 for x=1to3:read lv$(x):next x
  100 rem init
  101 poke 53281,6:poke 53272,21
  105 l%=1
  110 lv$=lv$(l%)
  114 rem level selected
  115 for x=0 to mx:pf%(x)=0:dl%(x)=-1:next x
  119 rem@ \slowfor
  120 i=0:for x=1tolen(lv$)
  122 t$=mid$(lv$,x,1)
  124 pf%(i)=asc(t$)and31
  125 i=i+1:if t$<"@" or t$>"_" then ifint(i/w)<i*0.1then 124
  128 nextx
  130 rem@ \fastfor
  150 fu=-1:rem undo underflow trigger
  155 for x=0 to mu:ud%(x,2)=fu:next x
  160 ud=0
  190 print"{clr}";
  200 rem begin main loop
  205 if win then win=0:l%=l%+1:goto110
  209 rem build rules
  210 for x=0 to 7:ru%(x)=0:next x
  215 poke 53280,5
  220 for dx=1 to w step (w-1):rem left-to-right and up-to-down
  230 for x=dx to mx-dx
  231 ifpf%(x)<>16 then 240
  232 n=pf%(x-dx)and31:if(n and 24)<>16 then 240
  233 n=n and 7:i=pf%(x+dx)and31
  235 if(iand24)=8 then ru%(n)=ru%(n)or2^(iand7):rem property
  236 if(iand24)=16 then ru%(n)=ru%(n)or((iand7)*256):rem transform
  240 rem todo: has/and or other verbs
  250 next x:poke 53280,3
  255 next dx:ru%(0)=0
  259 rem todo: replace fnpp with an array
  260 u=0:win=0:for n=0tomx
  261 i=fnpb(n)
  262 ifiand1thenu=1:ifiand2thenwin=1
  264 nextn:poke 53280,14
  265 rem drawscreen
  266 print"{home}";:for n=0tomx:printgr$(pf%(n)and31);:next n
  267 poke 646,14
  268 if u=0 then print"nothing is you. z=undo r=reset"
  269 if win then print"congratulations. press n for next"
  270 print"?    {left}{left}{left}{left}{left}";:wait198,15:getk$
  275 if k$="r" then 114:rem reset
  276 print asc(k$+".")"{left} "
  277 if k$="n" then l%=l%+1:goto 110:rem advance
  278 if k$="z" then 3000:rem undo
  280 if k$="p" then 700
  299 rem do all automata
  300 for x=0 to mx
  301 if pf%(x)and24 then 340
  305 if fnpp(x)and 1 then gosub 1000
  310 if fnpp(x)>255 then dl%(x)=fnpp(x)/256
  340 next x
  400 rem apply deltas
  410 forx=0tomx:if dl%(x)<0then420
  415 ud%(ud,0)=x:ud%(ud,1)=pf%(x):ud%(ud,2)=tu:u=1
  416 ud=ud+1:ifud>muthen ud=0
  419 pf%(x)=dl%(x):dl%(x)=-1
  420 next x
  424 rem only advance turn counter if undo stack has changed
  425 tu=tu+u:u=0
  426 fu=ud%(ud,2)
  450 goto 200:rem end of main loop
  700 rem poke
  710 input "poke";x,t$
  720 ift$>""andx>=0andx<=mxthen pf%(x)=asc(t$)and31:t$=mid$(t$,2):x=x+1:goto720
  730 goto 200
 1000 rem obj at x is you
 1001 dx=0
 1005 if k$="{rght}"thendx=1
 1006 if k$="{left}"thendx=-1
 1007 if k$="{down}"thendx=w
 1008 if k$="{up}"thendx=-w
 1009 if dx=0 then return
 1010 if x+dx<0 or x+dx>mx then return
 1020 if fnpp(x+dx)and2 then 6000:rem win
 1050 rem obj at x wants to move dx
 1055 ds=x+dx:ck=ds
 1060 ifck<0orck>mxthenreturn:rem stop at edge
 1061 if(fnpp(ck)and16)=0 then 1064
 1062 if(fnpp(ck-dx)and32) then 1086
 1063 return:rem shut
 1064 iffnpp(ck)and8 then ck=ck+dx:goto 1060:rem push property
 1065 ifpf%(ck)and24 then ck=ck+dx:goto 1060:rem push text
 1070 iffnpp(ck)and4then return:rem stop
 1079 rem shut=5 open=4
 1085 if(fnpp(ck)and64)=0 then 1090
 1086 dl%(ck)=0:ck=ck-dx:rem replace first with 0 to sink/open
 1089 rem@ \slowfor
 1090 for i=ck to ds step -dx
 1097 bg=pf%(i)and224:ifpf%(i)<8thenif(fnpp(i)and44)=0thenbg=pf%(i)*32
 1100 dl%(i)=(pf%(i-dx)and31)or bg
 1110 next i
 1111 rem@ \fastfor
 1120 ifdl%(x)=-1thendl%(x)=pf%(x)/32:rem restore bg
 1999 return
 3000 rem --undo--
 3010 rem@ \fastfor:\fastarray
 3030 tu=tu-1:u=0
 3040 print "undo move"tu"{left} under @"fu"{left} stk="ud"{left}/"mu
 3050 if tu<=fu then tu=fu+1:goto259
 3100 for x=0tomu
 3200 ifud%(x,2)=tuthenud%(x,2)=fu:pf%(ud%(x,0))=ud%(x,1):u=u+1
 3300 next x
 3350 ud=ud-u:if ud<0 then ud=ud+mu
 3360 print"new stk="ud"{left} "
 3400 goto 259:rem draw screen
 6000 print "congratulations. press any key"
 6010 poke198,0:wait 198,1
 6020 win=1:return

