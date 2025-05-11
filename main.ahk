#Singleinstance Force
#NoEnv
#KeyHistory, 0
SetBatchlines, -1

#Include utils.ahk

global GGT = "넷마블 파워쿵쿵따 Ver1.05"
global Address :=
(Join QC
{
	firstLetter: 0x00668398,
	is32: 0x006676B8,
	timing: 0x006682D0
}
)
global DooeumList := "
(LTrim Join
	냐냥녀녁년념녑녕뇨뇽뉴늉는니닉닌님닙닛닝
	라락란랄람랍랏랑랒래랩랫랭랴략량러럭런럴
	럼럽럿렁레렉렌렐렘렙렛려력련렬렴렵렷령례
	로록론롤롬롭롯롱뢰료룡루룩룬룰룹룽뤼류륙
	륜률르륵른름릅릉릎리릭린릴림립릿링
)"
global DooeumFix := "
(LTrim Join
	야양여역연염엽영요용유융은이익인임입잇잉
	나낙난날남납낫낭낮내냅냇냉야약양너넉넌널
	넘넙넛넝네넥넨넬넴넵넷여역연열염엽엿영예
	노녹논놀놈놉놋농뇌요용누눅눈눌눕눙뉘유육
	윤율느늑은늠늡능늪이익인일임입잇잉
)"
global NoManner33 := "
(LTrim Join
	값갸걀것겅곶귄긔기깽껌껍껑께꾼꿍넛넨넬늠
	늬니닦댄동둠듭듯럿름릅릇리맡맵먀멈면믈믿
	밋밍밖밧뱌볏볕봇붐붓빡뺨뼘삐샅샵섯섶섹션
	셜솥숍숏숲쉰쉽슘슛슭슴싹싼썽씀얀얌왓욧욹
	웍윅읍이잼쟈젯쥴즌즙짱쩍쭈쭉쯔찍챗챙첼츠
	칙칩캅캣켄켐켜콧퀵퀸텐톳틱틴틸팅팟퐁헨혀
	훌훼
)"
global Hanbang33 := "
(LTrim Join
	겟깅굉귿깅껏꼍꾹뀌낌냄넴녘뇰눔늄댜덟덥뎐
	듐듥딤딧랖랙륨뮴븀븨빰뺌뼉샬셉숌슨싯썹쎈
	씩엌욤윙윰읒읗잌젼좡죌쥭줴즘쨈쭝쯤챌쳐춰
	츨켓콕쿰큘킷탉텟튬튼팁펙퓸픈헴홉
)"
global Data
global DB
global SeriesLetter := ""

FileInstall, db.txt, %A_Temp%\db.txt, 0
FileInstall, euckr.txt, %A_Temp%\euckr.txt, 0

FileRead, Data, %A_Temp%\db.txt
FileRead, euckr, %A_Temp%\euckr.txt

FileDelete, %A_Temp%\db.txt
FileDelete, %A_Temp%\euckr.txt

InitializeDatabase()

return

Print:
	if ReadMemory(Address.timing) == 0 ; 1이면 내가 입력할 차례이거나 힌트를 주는 게 가능한 타이밍
	{
		return
	}

	firstLetterAscii := SubStr(Dec2Hex(ReadMemory(Address.firstLetter)), 3, 4)

	if !firstLetterAscii
	{
		return
	}

	RegExMatch(euckr, "m)^" . firstLetterAscii . "\K.", firstLetter)

	if InStr(DooeumList, firstLetter)
	{
		firstLetter := SubStr(DooeumFix, InStr(DooeumList, firstLetter), 1)
	}

	n := ReadMemory(Address.is32) = 1 ? 1 : 2 ; 1이면 3-2이고 0이거나 255이면 3-3

	if SeriesLetter
	{
		RegExMatch(DB, "m)^" . firstLetter . ".{" . (n - 1) . "}[" SeriesLetter "]$", word)
	}
	else
	{
		RegExMatch(DB, "m)^" . firstLetter . ".{" . n  . "}$", word)
	}

	if !word
	{
		if !RegExMatch(DB, "m)^" . firstLetter . ".{" . n . "}$", word)
		{
			RegExMatch(Data, "m)^" . firstLetter . ".{" . n . "}$", word)
		}
	}

	WinActive(GGT) ? ActiveSend(word) : InactiveSend(word)

	DB := StrReplace(DB, word, , 0, -1)
	word := ""

	Sleep, 200

	return

InitializeDatabase()
{
	ShuffleWords()
	FilterWords()
}

ShuffleWords()
{
	Sort, Data, Random

	DB := Data
}

FilterWords()
{
	hanbangFilter := "m)^[가-힣]{2}[" . Hanbang33 . "]$"
	noMannerFilter := "m)^[가-힣]{2}[" . NoManner33 . "]$"
	noMannerWords := ""
	foundPos := 1
	
	DB := RegExReplace(DB, hanbangFilter)

	while foundPos := RegExMatch(DB, noMannerFilter, noMannerWord, foundPos + StrLen(noMannerWord))
	{
		noMannerWords .= noMannerWord . "`r`n"
	}

	DB := RegExReplace(DB, noMannerFilter) . "`r`n" . noMannerWords
}

ActiveSend(word)
{
	SendInput, {Enter}%word%{Enter}

	return
}

InactiveSend(word)
{
	ControlFocus, Edit5, % GGT
	ControlSetText, Edit5, , % GGT
	ControlSend, Edit5, %word%{Enter}, % GGT

	return
}

Alt::goto, Print
F7::ShuffleWords()
F8::InputBox, SeriesLetter, 시리즈를 입력하세요! (빈칸 - 시리즈 사용안함), 시리즈 설정
F9::MsgBox, % SeriesLetter
F10::Pause
F11::Reload
F12::ExitApp
