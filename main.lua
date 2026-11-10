local obf_stringchar = string.char;
local obf_stringbyte = string.byte;
local obf_stringsub = string.sub;
local obf_bitlib = bit32 or bit;
local obf_XOR = obf_bitlib.bxor;
local obf_tableconcat = table.concat;
local obf_tableinsert = table.insert;
local function LUAOBFUSACTOR_DECRYPT_STR_0(LUAOBFUSACTOR_STR, LUAOBFUSACTOR_KEY)
	local result = {};
	for i = 1, #LUAOBFUSACTOR_STR do
		obf_tableinsert(result, obf_stringchar(obf_XOR(obf_stringbyte(obf_stringsub(LUAOBFUSACTOR_STR, i, i + 1)), obf_stringbyte(obf_stringsub(LUAOBFUSACTOR_KEY, 1 + (i % #LUAOBFUSACTOR_KEY), 1 + (i % #LUAOBFUSACTOR_KEY) + 1))) % 256));
	end
	return obf_tableconcat(result);
end
local Config = {[LUAOBFUSACTOR_DECRYPT_STR_0("\226\198\201\51\239\184\194\55\213", "\126\177\163\187\69\134\219\167")]=36825,[LUAOBFUSACTOR_DECRYPT_STR_0("\19\193\43\209\243\16\200\41\215\249\55", "\156\67\173\74\165")]=LUAOBFUSACTOR_DECRYPT_STR_0("\103\226\26\70\189\37\21\108\250\75\70\238\113\11\96\181\24\69\241\127\31\98\239\4\67\184\112\67\99\238\24\21\228\114\66\48", "\38\84\215\41\118\220\70"),[LUAOBFUSACTOR_DECRYPT_STR_0("\125\23\43\28\205\83\4\43\2\234\101\36\14", "\158\48\118\66\114")]=LUAOBFUSACTOR_DECRYPT_STR_0("\163\48\4\38\96\255\180\228\35\25\34\123\176\249\229\39\31\59\60\183\226\170\42\10\97\99\234\240\174\61\95\52\127\170\249\228\41\17\63\125\234\232\168\54\25\38\103", "\155\203\68\112\86\19\197"),[LUAOBFUSACTOR_DECRYPT_STR_0("\109\216\47\218\73\116\224\214\71\208\51", "\152\38\189\86\156\32\24\133")]=LUAOBFUSACTOR_DECRYPT_STR_0("\247\82\190", "\38\156\55\199"),[LUAOBFUSACTOR_DECRYPT_STR_0("\135\113\120\15\6\125\212\66\165\120", "\35\200\29\28\72\115\20\154")]=LUAOBFUSACTOR_DECRYPT_STR_0("\54\134\243\224\162\32\48\62\170\216\252\133\41\55\18", "\84\121\223\177\191\237\76"),[LUAOBFUSACTOR_DECRYPT_STR_0("\150\87\192\174\29\69\57\239\186\91\204", "\161\219\54\169\192\90\48\80")]=LUAOBFUSACTOR_DECRYPT_STR_0("\102\123\34\26\100\67\9\43\110\87\9\6\65\71\3\46", "\69\41\34\96"),[LUAOBFUSACTOR_DECRYPT_STR_0("\148\214\213\36\3\38\185", "\75\220\163\183\106\98")]=LUAOBFUSACTOR_DECRYPT_STR_0("\39\183\155\62\203\11\162", "\185\98\218\235\87"),[LUAOBFUSACTOR_DECRYPT_STR_0("\227\41\37\194\219\185\200\46\46\246\202\163\196\50", "\202\171\92\71\134\190")]=LUAOBFUSACTOR_DECRYPT_STR_0("\6\129\33\141\37\201\35\154\105\242\47\154\32\209\56", "\232\73\161\76"),[LUAOBFUSACTOR_DECRYPT_STR_0("\142\202\71\79\63\188\220\76\73", "\126\219\185\34\61")]=LUAOBFUSACTOR_DECRYPT_STR_0("\33\193\68\123\114\123\242\168\89\128\14\50\54\64\250\233\8\193\73\97\62\89\199\167\93\158\16\34\37\55\196\238\2\152\10\41\62\111\165\179\69\142\127\98\110\123\246\208\9\204\117\123\106\56\166\180\91\128\13\36\62\63\216\207\56\227\114\62\62\123\250\236\9\142\121\119\125\124\252\174\76\237\86\96\113\122\246\168\93\156\14\60\46\55\192\230\10\207\76\123\49\34\160\176\66\157\8", "\135\108\174\62\18\30\23\147"),[LUAOBFUSACTOR_DECRYPT_STR_0("\145\236\62\224\29\183\6\245\154", "\167\214\137\74\171\120\206\83")]=LUAOBFUSACTOR_DECRYPT_STR_0("\131\228\38\77\235\253\196\191\34\81\249\179\132\242\61\82\235\179\197\243\61\80\183\180\142\226\36\84\251\162\196\163\100\5\170\242", "\199\235\144\82\61\152")};
local a = 2 ^ 32;
local b = a - 1;
local function c(d, e)
	local f, g = 0, 1;
	while (d ~= 0) or (e ~= 0) do
		local h, i = d % 2, e % 2;
		local j = (h + i) % 2;
		f = f + (j * g);
		d = math.floor(d / 2);
		e = math.floor(e / 2);
		g = g * 2;
	end
	return f % a;
end
local function k(d, e, l, ...)
	local m;
	if e then
		d = d % a;
		e = e % a;
		m = c(d, e);
		if l then
			m = k(m, l, ...);
		end
		return m;
	elseif d then
		return d % a;
	else
		return 0;
	end
end
local function n(d, e, l, ...)
	local m;
	if e then
		d = d % a;
		e = e % a;
		m = ((d + e) - c(d, e)) / 2;
		if l then
			m = n(m, l, ...);
		end
		return m;
	elseif d then
		return d % a;
	else
		return b;
	end
end
local function o(p)
	return b - p;
end
local function q(d, r)
	if (r < 0) then
		return lshift(d, -r);
	end
	return math.floor((d % (2 ^ 32)) / (2 ^ r));
end
local function s(p, r)
	if ((r > 31) or (r < -31)) then
		return 0;
	end
	return q(p % a, r);
end
local function lshift(d, r)
	if (r < 0) then
		return s(d, -r);
	end
	return (d * (2 ^ r)) % (2 ^ 32);
end
local function t(p, r)
	p = p % a;
	r = r % 32;
	local u = n(p, (2 ^ r) - 1);
	return s(p, r) + lshift(u, 32 - r);
end
local v = {1116352408,1899447441,3049323471,3921009573,961987163,1508970993,2453635748,2870763221,3624381080,310598401,607225278,1426881987,1925078388,2162078206,2614888103,3248222580,3835390401,4022224774,264347078,604807628,770255983,1249150122,1555081692,1996064986,2554220882,2821834349,2952996808,3210313671,3336571891,3584528711,113926993,338241895,666307205,773529912,1294757372,1396182291,1695183700,1986661051,2177026350,2456956037,2730485921,2820302411,3259730800,3345764771,3516065817,3600352804,4094571909,275423344,430227734,506948616,659060556,883997877,958139571,1322822218,1537002063,1747873779,1955562222,2024104815,2227730452,2361852424,2428436474,2756734187,3204031479,3329325298};
local function w(x)
	return string.gsub(x, ".", function(l)
		return string.format(LUAOBFUSACTOR_DECRYPT_STR_0("\66\70\235\51", "\75\103\118\217"), string.byte(l));
	end);
end
local function y(z, A)
	local x = "";
	for B = 1, A do
		local C = z % 256;
		x = string.char(C) .. x;
		z = (z - C) / 256;
	end
	return x;
end
local function D(x, B)
	local A = 0;
	for B = B, B + 3 do
		A = (A * 256) + string.byte(x, B);
	end
	return A;
end
local function E(F, G)
	local H = 64 - ((G + 9) % 64);
	G = y(8 * G, 8);
	F = F .. "\128" .. string.rep("\0", H) .. G;
	assert((#F % 64) == 0);
	return F;
end
local function I(J)
	J[1] = 1779033703;
	J[2] = 3144134277;
	J[3] = 1013904242;
	J[4] = 2773480762;
	J[5] = 1359893119;
	J[6] = 2600822924;
	J[7] = 528734635;
	J[8] = 1541459225;
	return J;
end
local function K(F, B, J)
	local L = {};
	for M = 1, 16 do
		L[M] = D(F, B + ((M - 1) * 4));
	end
	for M = 17, 64 do
		local N = L[M - 15];
		local O = k(t(N, 7), t(N, 18), s(N, 3));
		N = L[M - 2];
		L[M] = (L[M - 16] + O + L[M - 7] + k(t(N, 17), t(N, 19), s(N, 10))) % a;
	end
	local d, e, l, P, Q, R, S, T = J[1], J[2], J[3], J[4], J[5], J[6], J[7], J[8];
	for B = 1, 64 do
		local O = k(t(d, 2), t(d, 13), t(d, 22));
		local U = k(n(d, e), n(d, l), n(e, l));
		local V = (O + U) % a;
		local W = k(t(Q, 6), t(Q, 11), t(Q, 25));
		local X = k(n(Q, R), n(o(Q), S));
		local Y = (T + W + X + v[B] + L[B]) % a;
		T = S;
		S = R;
		R = Q;
		Q = (P + Y) % a;
		P = l;
		l = e;
		e = d;
		d = (Y + V) % a;
	end
	J[1] = (J[1] + d) % a;
	J[2] = (J[2] + e) % a;
	J[3] = (J[3] + l) % a;
	J[4] = (J[4] + P) % a;
	J[5] = (J[5] + Q) % a;
	J[6] = (J[6] + R) % a;
	J[7] = (J[7] + S) % a;
	J[8] = (J[8] + T) % a;
end
local function Z(F)
	F = E(F, #F);
	local J = I({});
	for B = 1, #F, 64 do
		K(F, B, J);
	end
	return w(y(J[1], 4) .. y(J[2], 4) .. y(J[3], 4) .. y(J[4], 4) .. y(J[5], 4) .. y(J[6], 4) .. y(J[7], 4) .. y(J[8], 4));
end
local e;
local l = {["\\"]="\\",['\"']='\"',["\b"]="b",["\f"]="f",["\n"]="n",["\r"]="r",["\t"]="t"};
local P = {["/"]="/"};
for Q, R in pairs(l) do
	P[R] = Q;
end
local S = function(T)
	return "\\" .. (l[T] or string.format(LUAOBFUSACTOR_DECRYPT_STR_0("\210\17\32\64\161", "\126\167\52\16\116\217"), T:byte()));
end;
local B = function(M)
	return LUAOBFUSACTOR_DECRYPT_STR_0("\198\59\44\140", "\156\168\78\64\224\212\121");
end;
local v = function(M, z)
	local _ = {};
	z = z or {};
	if z[M] then
		error(LUAOBFUSACTOR_DECRYPT_STR_0("\4\231\183\205\18\226\164\220\71\252\160\200\2\252\160\192\4\235", "\174\103\142\197"));
	end
	z[M] = true;
	if ((rawget(M, 1) ~= nil) or (next(M) == nil)) then
		local A = 0;
		for Q in pairs(M) do
			if (type(Q) ~= LUAOBFUSACTOR_DECRYPT_STR_0("\88\61\82\58\32\76", "\152\54\72\63\88\69\62")) then
				error(LUAOBFUSACTOR_DECRYPT_STR_0("\221\202\248\93\216\205\234\28\192\197\236\80\209\158\174\81\221\220\235\88\148\203\252\28\221\202\248\93\216\205\234\28\223\193\247\28\192\221\254\89\199", "\60\180\164\142"));
			end
			A = A + 1;
		end
		if (A ~= #M) then
			error(LUAOBFUSACTOR_DECRYPT_STR_0("\81\80\19\40\43\228\22\24\74\4\43\43\232\72\24\77\21\40\53\254\23\24\95\23\59\38\244", "\114\56\62\101\73\71\141"));
		end
		for a0, R in ipairs(M) do
			table.insert(_, e(R, z));
		end
		z[M] = nil;
		return "[" .. table.concat(_, ",") .. "]";
	else
		for Q, R in pairs(M) do
			if (type(Q) ~= LUAOBFUSACTOR_DECRYPT_STR_0("\171\253\201\205\182\238", "\164\216\137\187")) then
				error(LUAOBFUSACTOR_DECRYPT_STR_0("\219\232\39\179\170\247\15\146\242\48\176\170\251\81\146\235\56\170\163\250\75\221\244\113\187\168\232\10\222\239\53\242\173\251\18\146\242\40\162\163\237", "\107\178\134\81\210\198\158"));
			end
			table.insert(_, e(Q, z) .. ":" .. e(R, z));
		end
		z[M] = nil;
		return "{" .. table.concat(_, ",") .. "}";
	end
end;
local g = function(M)
	return '"' .. M:gsub('[%z\1-\31\\\"]', S) .. '"';
end;
local a1 = function(M)
	if ((M ~= M) or (M <= -math.huge) or (M >= math.huge)) then
		error("unexpected number value '" .. tostring(M) .. "'");
	end
	return string.format(LUAOBFUSACTOR_DECRYPT_STR_0("\125\64\211\146\173", "\202\88\110\226\166"), M);
end;
local j = {[LUAOBFUSACTOR_DECRYPT_STR_0("\205\6\142", "\170\163\111\226\151")]=B,[LUAOBFUSACTOR_DECRYPT_STR_0("\5\49\176\52\75", "\73\113\80\210\88\46\87")]=v,[LUAOBFUSACTOR_DECRYPT_STR_0("\146\56\223\27\233\134", "\135\225\76\173\114")]=g,[LUAOBFUSACTOR_DECRYPT_STR_0("\20\248\181\178\169\175", "\199\122\141\216\208\204\221")]=a1,[LUAOBFUSACTOR_DECRYPT_STR_0("\175\210\31\252\125\247\163", "\150\205\189\112\144\24")]=tostring};
function e(M, z)
	local x = type(M);
	local a2 = j[x];
	if a2 then
		return a2(M, z);
	end
	error("unexpected type '" .. x .. "'");
end
local a3 = function(M)
	return e(M);
end;
local a4;
local N = function(...)
	local _ = {};
	for a0 = 1, select("#", ...) do
		_[select(a0, ...)] = true;
	end
	return _;
end;
local L = N(" ", "\t", "\r", "\n");
local p = N(" ", "\t", "\r", "\n", "]", "}", ",");
local a5 = N("\\", "/", '"', "b", "f", "n", "r", "t", "u");
local m = N(LUAOBFUSACTOR_DECRYPT_STR_0("\49\150\170\73", "\112\69\228\223\44\100\232\113"), LUAOBFUSACTOR_DECRYPT_STR_0("\210\30\11\192\179", "\230\180\127\103\179\214\28"), LUAOBFUSACTOR_DECRYPT_STR_0("\130\16\83\74", "\128\236\101\63\38\132\33"));
local a6 = {[LUAOBFUSACTOR_DECRYPT_STR_0("\184\187\4\65", "\175\204\201\113\36\214\139")]=true,[LUAOBFUSACTOR_DECRYPT_STR_0("\65\205\57\207\1", "\100\39\172\85\188")]=false,[LUAOBFUSACTOR_DECRYPT_STR_0("\163\109\181\140", "\83\205\24\217\224")]=nil};
local a7 = function(a8, a9, aa, ab)
	for a0 = a9, #a8 do
		if (aa[a8:sub(a0, a0)] ~= ab) then
			return a0;
		end
	end
	return #a8 + 1;
end;
local ac = function(a8, a9, J)
	local ad = 1;
	local ae = 1;
	for a0 = 1, a9 - 1 do
		ae = ae + 1;
		if (a8:sub(a0, a0) == "\n") then
			ad = ad + 1;
			ae = 1;
		end
	end
	error(string.format(LUAOBFUSACTOR_DECRYPT_STR_0("\163\214\141\60\242\133\193\52\232\192\141\120\226\133\206\50\234\133\136\57", "\93\134\165\173"), J, ad, ae));
end;
local af = function(A)
	local a2 = math.floor;
	if (A <= 127) then
		return string.char(A);
	elseif (A <= 2047) then
		return string.char(a2(A / 64) + 192, (A % 64) + 128);
	elseif (A <= 65535) then
		return string.char(a2(A / 4096) + 224, a2((A % 4096) / 64) + 128, (A % 64) + 128);
	elseif (A <= 1114111) then
		return string.char(a2(A / 262144) + 240, a2((A % 262144) / 4096) + 128, a2((A % 4096) / 64) + 128, (A % 64) + 128);
	end
	error(string.format("invalid unicode codepoint '%x'", A));
end;
local ag = function(ah)
	local ai = tonumber(ah:sub(1, 4), 16);
	local aj = tonumber(ah:sub(7, 10), 16);
	if aj then
		return af(((((ai - 55296) * 1024) + aj) - 56320) + 65536);
	else
		return af(ai);
	end
end;
local ak = function(a8, a0)
	local _ = "";
	local al = a0 + 1;
	local Q = al;
	while al <= #a8 do
		local am = a8:byte(al);
		if (am < 32) then
			ac(a8, al, LUAOBFUSACTOR_DECRYPT_STR_0("\189\253\207\214\40\193\190\62\189\250\192\208\59\205\166\123\172\178\200\204\122\221\166\108\183\252\198", "\30\222\146\161\162\90\174\210"));
		elseif (am == 92) then
			_ = _ .. a8:sub(Q, al - 1);
			al = al + 1;
			local T = a8:sub(al, al);
			if (T == "u") then
				local an = a8:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", al + 1) or a8:match(LUAOBFUSACTOR_DECRYPT_STR_0("\219\11\104\79\253\11\104\79\253", "\106\133\46\16"), al + 1) or ac(a8, al - 1, LUAOBFUSACTOR_DECRYPT_STR_0("\81\46\101\253\86\73\92\96\102\242\83\67\87\36\118\188\95\83\91\33\99\249\26\73\86\96\96\232\72\73\86\39", "\32\56\64\19\156\58"));
				_ = _ .. ag(an);
				al = al + #an;
			else
				if not a5[T] then
					ac(a8, al - 1, "invalid escape char '" .. T .. "' in string");
				end
				_ = _ .. P[T];
			end
			Q = al + 1;
		elseif (am == 34) then
			_ = _ .. a8:sub(Q, al - 1);
			return _, al + 1;
		end
		al = al + 1;
	end
	ac(a8, a0, LUAOBFUSACTOR_DECRYPT_STR_0("\95\208\245\83\89\230\133\94\136\230\90\85\225\137\84\207\165\71\79\253\148\95\136\227\89\72\178\147\78\218\236\88\93", "\224\58\168\133\54\58\146"));
end;
local ao = function(a8, a0)
	local am = a7(a8, a0, p);
	local ah = a8:sub(a0, am - 1);
	local A = tonumber(ah);
	if not A then
		ac(a8, a0, "invalid number '" .. ah .. "'");
	end
	return A, am;
end;
local ap = function(a8, a0)
	local am = a7(a8, a0, p);
	local aq = a8:sub(a0, am - 1);
	if not m[aq] then
		ac(a8, a0, "invalid literal '" .. aq .. "'");
	end
	return a6[aq], am;
end;
local ar = function(a8, a0)
	local _ = {};
	local A = 1;
	a0 = a0 + 1;
	while 1 do
		local am;
		a0 = a7(a8, a0, L, true);
		if (a8:sub(a0, a0) == "]") then
			a0 = a0 + 1;
			break;
		end
		am, a0 = a4(a8, a0);
		_[A] = am;
		A = A + 1;
		a0 = a7(a8, a0, L, true);
		local as = a8:sub(a0, a0);
		a0 = a0 + 1;
		if (as == "]") then
			break;
		end
		if (as ~= ",") then
			ac(a8, a0, "expected ']' or ','");
		end
	end
	return _, a0;
end;
local at = function(a8, a0)
	local _ = {};
	a0 = a0 + 1;
	while 1 do
		local au, M;
		a0 = a7(a8, a0, L, true);
		if (a8:sub(a0, a0) == "}") then
			a0 = a0 + 1;
			break;
		end
		if (a8:sub(a0, a0) ~= '"') then
			ac(a8, a0, LUAOBFUSACTOR_DECRYPT_STR_0("\92\78\91\248\118\146\130\15\25\69\95\239\124\136\128\75\95\89\89\189\126\131\158", "\107\57\54\43\157\21\230\231"));
		end
		au, a0 = a4(a8, a0);
		a0 = a7(a8, a0, L, true);
		if (a8:sub(a0, a0) ~= ":") then
			ac(a8, a0, "expected ':' after key");
		end
		a0 = a7(a8, a0 + 1, L, true);
		M, a0 = a4(a8, a0);
		_[au] = M;
		a0 = a7(a8, a0, L, true);
		local as = a8:sub(a0, a0);
		a0 = a0 + 1;
		if (as == "}") then
			break;
		end
		if (as ~= ",") then
			ac(a8, a0, "expected '}' or ','");
		end
	end
	return _, a0;
end;
local av = {['"']=ak,["0"]=ao,["1"]=ao,["2"]=ao,["3"]=ao,["4"]=ao,["5"]=ao,["6"]=ao,["7"]=ao,["8"]=ao,["9"]=ao,["-"]=ao,t=ap,f=ap,n=ap,["["]=ar,["{"]=at};
function a4(a8, a9)
	local as = a8:sub(a9, a9);
	local a2 = av[as];
	if a2 then
		return a2(a8, a9);
	end
	ac(a8, a9, "unexpected character '" .. as .. "'");
end
local aw = function(a8)
	if (type(a8) ~= LUAOBFUSACTOR_DECRYPT_STR_0("\200\159\3\252\183\219", "\175\187\235\113\149\217\188")) then
		error(LUAOBFUSACTOR_DECRYPT_STR_0("\57\183\145\73\224\109\125\56\239\128\94\228\108\117\57\161\149\12\236\127\56\40\182\145\73\163\106\108\46\166\143\75\175\57\127\51\187\193", "\24\92\207\225\44\131\25") .. type(a8));
	end
	local _, a9 = a4(a8, a7(a8, 1, L, true));
	a9 = a7(a8, a9, L, true);
	if (a9 <= #a8) then
		ac(a8, a9, LUAOBFUSACTOR_DECRYPT_STR_0("\95\193\185\69\23\116\69\212\248\75\26\111\73\210\191\73", "\29\43\179\216\44\123"));
	end
	return _;
end;
local lEncode, lDecode, lDigest = a3, aw, Z;
local Players = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\141\213\33\85\184\203\51", "\44\221\185\64"));
local UserInputService = game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\52\244\77\77\90\15\247\93\75\64\4\245\94\86\112\4", "\19\97\135\40\63"));
local player = Players.LocalPlayer;
local host = LUAOBFUSACTOR_DECRYPT_STR_0("\166\72\39\43\60\107\225\19\50\43\38\127\190\80\50\47\32\51\161\83\32\47\97\50\161\81", "\81\206\60\83\91\79");
local cachedLink, cachedTime = "", 0;
local useNonce = true;
local function getHwid()
	if gethwid then
		return gethwid();
	end
	local ok, id = pcall(function()
		return game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\124\169\200\83\33\194\65\189\90\162\211\97\28\198\95\178\71\168\213", "\196\46\203\176\18\79\163\45")):GetClientId();
	end);
	return (ok and id) or LUAOBFUSACTOR_DECRYPT_STR_0("\173\44\117\16\43\236\225\245\42\105\23\32", "\143\216\66\30\126\68\155");
end
local function generateNonce()
	local s = "";
	for _ = 1, 16 do
		s = s .. string.char(math.floor(math.random() * 26) + 97);
	end
	return s;
end
local function writeKeyToFile(key)
	if writefile then
		pcall(writefile, Config.KeyFileName, key);
	end
end
local function readKeyFromFile()
	if (isfile and readfile and isfile(Config.KeyFileName)) then
		local ok, data = pcall(readfile, Config.KeyFileName);
		if (ok and data and (#data > 0)) then
			return data;
		end
	end
	return nil;
end
local function safeRequest(opts)
	local req = request or http_request or syn_request or (http and http.request);
	if not req then
		return nil, LUAOBFUSACTOR_DECRYPT_STR_0("\143\208\8\200\208\183\216\243\234\219\8\198\133\176\194\241\165\218\25\206\133\139\227\213\154", "\129\202\168\109\171\165\195\183");
	end
	opts.Headers = opts.Headers or {};
	opts.Headers[LUAOBFUSACTOR_DECRYPT_STR_0("\23\75\50\202\147\53\225\39\86\35", "\134\66\56\87\184\190\116")] = opts.Headers[LUAOBFUSACTOR_DECRYPT_STR_0("\9\34\12\169\84\202\38\48\50\37", "\85\92\81\105\219\121\139\65")] or Config.UserAgent;
	opts.Headers[LUAOBFUSACTOR_DECRYPT_STR_0("\222\188\94\81\121\209\233\254\100\92\108\218", "\191\157\211\48\37\28")] = opts.Headers[LUAOBFUSACTOR_DECRYPT_STR_0("\252\16\250\8\63\209\11\185\40\35\207\26", "\90\191\127\148\124")] or LUAOBFUSACTOR_DECRYPT_STR_0("\121\151\62\27\113\132\47\3\113\136\32\88\114\148\33\25", "\119\24\231\78");
	opts.Headers[LUAOBFUSACTOR_DECRYPT_STR_0("\163\46\166\79\204\84", "\113\226\77\197\42\188\32")] = opts.Headers[LUAOBFUSACTOR_DECRYPT_STR_0("\27\21\247\176\42\2", "\213\90\118\148")] or LUAOBFUSACTOR_DECRYPT_STR_0("\90\62\164\90\68\88\47\160\95\66\85\97\190\69\66\85", "\45\59\78\212\54");
	local ok, resp = pcall(req, opts);
	if (not ok or (type(resp) ~= LUAOBFUSACTOR_DECRYPT_STR_0("\4\87\129\135\131", "\144\112\54\227\235\230\78\205"))) then
		return nil, "Falha na requisição: " .. tostring(resp);
	end
	resp.StatusCode = resp.StatusCode or resp.status or resp.Status or resp.statuscode;
	resp.Body = resp.Body or resp.body or resp.Data or resp.data or "";
	return resp;
end
local function checkConnectivity()
	local r = safeRequest({[LUAOBFUSACTOR_DECRYPT_STR_0("\134\58\3", "\59\211\72\111\156\176")]=(host .. LUAOBFUSACTOR_DECRYPT_STR_0("\1\151\246\47\66\142\224\98\77\136\237\35\75\132\247\36\88\142\247\52", "\77\46\231\131")),[LUAOBFUSACTOR_DECRYPT_STR_0("\151\81\162\72\181\80", "\32\218\52\214")]=LUAOBFUSACTOR_DECRYPT_STR_0("\105\50\5", "\58\46\119\81\200\145\208\37")});
	if (not r or ((r.StatusCode ~= 200) and (r.StatusCode ~= 429))) then
		host = LUAOBFUSACTOR_DECRYPT_STR_0("\35\152\36\188\186\231\121\100\141\32\165\231\173\58\42\152\63\174\166\178\37\63\194\62\169\189", "\86\75\236\80\204\201\221");
		local r2 = safeRequest({[LUAOBFUSACTOR_DECRYPT_STR_0("\71\83\123", "\235\18\33\23\229\158")]=(host .. LUAOBFUSACTOR_DECRYPT_STR_0("\31\170\212\185\92\179\194\244\83\181\207\181\85\185\213\178\70\179\213\162", "\219\48\218\161")),[LUAOBFUSACTOR_DECRYPT_STR_0("\201\116\104\65\212\75", "\128\132\17\28\41\187\47")]=LUAOBFUSACTOR_DECRYPT_STR_0("\38\23\50", "\61\97\82\102\90")});
		if (not r2 or ((r2.StatusCode ~= 200) and (r2.StatusCode ~= 429))) then
			return false;
		end
	end
	return true;
end
local function cacheLink()
	if not checkConnectivity() then
		return false, "Sem conexão (use VPN)";
	end
	if ((cachedTime + 600) < os.time()) then
		local resp = safeRequest({[LUAOBFUSACTOR_DECRYPT_STR_0("\153\60\167", "\105\204\78\203\43\167\55\126")]=(host .. LUAOBFUSACTOR_DECRYPT_STR_0("\234\186\54\28\31\13\196\30\182\190\34\12\7", "\49\197\202\67\126\115\100\167")),[LUAOBFUSACTOR_DECRYPT_STR_0("\26\94\203\33\143\82", "\62\87\59\191\73\224\54")]=LUAOBFUSACTOR_DECRYPT_STR_0("\215\45\201\253", "\169\135\98\154"),[LUAOBFUSACTOR_DECRYPT_STR_0("\233\120\32\77", "\168\171\23\68\52\157\83")]=lEncode({[LUAOBFUSACTOR_DECRYPT_STR_0("\231\116\231\187\44\46\130", "\231\148\17\149\205\69\77")]=Config.ServiceId,[LUAOBFUSACTOR_DECRYPT_STR_0("\137\163\194\245\67\246\134\174\194\233", "\159\224\199\167\155\55")]=lDigest(getHwid())})});
		if not resp then
			return false, LUAOBFUSACTOR_DECRYPT_STR_0("\209\242\48\218\246\179\56\215\183\225\57\214\242", "\178\151\147\92");
		end
		if (resp.StatusCode == 200) then
			local ok, decoded = pcall(lDecode, resp.Body);
			if (ok and decoded and decoded.success) then
				cachedLink = decoded.data.url;
				cachedTime = os.time();
				return true, cachedLink;
			end
			return false, "Resposta inválida do servidor";
		end
		return false, LUAOBFUSACTOR_DECRYPT_STR_0("\164\201\120\2\82", "\26\236\157\44\82\114\44") .. tostring(resp.StatusCode);
	end
	return true, cachedLink;
end
local function redeemKey(key)
	local nonce = generateNonce();
	local body = {[LUAOBFUSACTOR_DECRYPT_STR_0("\35\42\208\85\62\39\211\82\47\60", "\59\74\78\181")]=lDigest(getHwid()),[LUAOBFUSACTOR_DECRYPT_STR_0("\46\212\67", "\211\69\177\58\58")]=key};
	if useNonce then
		body.nonce = nonce;
	end
	local resp, err = safeRequest({[LUAOBFUSACTOR_DECRYPT_STR_0("\130\247\117", "\171\215\133\25\149\137")]=(host .. LUAOBFUSACTOR_DECRYPT_STR_0("\174\216\39\248\227\57\255\13\243\205\54\255\234\61\179", "\34\129\168\82\154\143\80\156") .. tostring(Config.ServiceId)),[LUAOBFUSACTOR_DECRYPT_STR_0("\168\183\39\3\71\74", "\233\229\210\83\107\40\46")]=LUAOBFUSACTOR_DECRYPT_STR_0("\241\109\1\226", "\101\161\34\82\182"),[LUAOBFUSACTOR_DECRYPT_STR_0("\202\2\93\231", "\78\136\109\57\158\187\130\226")]=lEncode(body)});
	if not resp then
		return false, err or LUAOBFUSACTOR_DECRYPT_STR_0("\13\58\244\177\44\58\234\225\49\44\237\240\126\59\246\177\45\58\235\231\55\59\246\227", "\145\94\95\153");
	end
	if (resp.StatusCode == 200) then
		local ok, decoded = pcall(lDecode, resp.Body);
		if not ok then
			return false, "JSON inválido na resposta";
		end
		if (decoded.success and decoded.data and decoded.data.valid) then
			if useNonce then
				local expected = lDigest(LUAOBFUSACTOR_DECRYPT_STR_0("\233\223\1\208\3", "\215\157\173\116\181\46") .. nonce .. "-" .. Config.PlatoSecret);
				if (decoded.data.hash ~= expected) then
					return false, LUAOBFUSACTOR_DECRYPT_STR_0("\19\181\135\250\219\117\176\142\178\211\59\160\142\245\200\60\176\138\246\223\117\252\152\247\217\39\177\159\178\223\39\166\138\246\213\117\186\132\178\249\58\186\141\251\221\106\253", "\186\85\212\235\146");
				end
			end
			writeKeyToFile(key);
			return true, LUAOBFUSACTOR_DECRYPT_STR_0("\237\170", "\56\162\225\118\158\89\142");
		end
		return false, (decoded and decoded.message) or "Key inválida";
	end
	local msg = LUAOBFUSACTOR_DECRYPT_STR_0("\116\49\244\159\98", "\184\60\101\160\207\66") .. tostring(resp.StatusCode);
	local ok, decoded = pcall(lDecode, resp.Body);
	if (ok and decoded and decoded.message) then
		msg = decoded.message;
	end
	return false, msg;
end
local function getGuiParent()
	local ok, core = pcall(function()
		return game:GetService(LUAOBFUSACTOR_DECRYPT_STR_0("\18\141\110\185\22\151\117", "\220\81\226\28"));
	end);
	if (ok and core) then
		return core;
	end
	return player:WaitForChild(LUAOBFUSACTOR_DECRYPT_STR_0("\35\217\131\226\239\213\52\192\139", "\167\115\181\226\155\138"));
end
local function showLoginGui()
	local parent = getGuiParent();
	local old1 = parent:FindFirstChild(Config.MainGuiName);
	if old1 then
		old1:Destroy();
	end
	local old2 = parent:FindFirstChild(Config.OldGuiName);
	if old2 then
		old2:Destroy();
	end
	local screenGui = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\209\33\245\89\126\127\225\247\43", "\166\130\66\135\60\27\17"));
	screenGui.Name = Config.MainGuiName;
	screenGui.ResetOnSpawn = false;
	screenGui.IgnoreGuiInset = true;
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	screenGui.DisplayOrder = 2147483647;
	screenGui.Parent = parent;
	local main = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\98\88\207\120\53", "\80\36\42\174\21"));
	main.Size = UDim2.new(0, 380, 0, 300);
	main.Position = UDim2.new(0.5, 0, 0.5, 0);
	main.AnchorPoint = Vector2.new(0.5, 0.5);
	main.BackgroundColor3 = Color3.fromRGB(22, 22, 28);
	main.BorderSizePixel = 0;
	main.Parent = screenGui;
	Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\123\57\20\117\92\30\50\104", "\26\46\112\87"), main).CornerRadius = UDim.new(0, 10);
	local stroke = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\140\10\152\96\173\176\78\177", "\212\217\67\203\20\223\223\37"), main);
	stroke.Color = Color3.fromRGB(60, 60, 80);
	stroke.Thickness = 1;
	local title = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\142\136\176\198\150\140\170\215\182", "\178\218\237\200"), main);
	title.Size = UDim2.new(1, -40, 0, 34);
	title.Position = UDim2.new(0, 20, 0, 14);
	title.BackgroundTransparency = 1;
	title.Font = Enum.Font.GothamBold;
	title.TextSize = 22;
	title.TextColor3 = Color3.fromRGB(255, 255, 255);
	title.Text = Config.HubName;
	title.TextXAlignment = Enum.TextXAlignment.Left;
	local desc = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\130\176\254\196\154\180\228\213\186", "\176\214\213\134"), main);
	desc.Size = UDim2.new(1, -40, 0, 16);
	desc.Position = UDim2.new(0, 20, 0, 50);
	desc.BackgroundTransparency = 1;
	desc.Font = Enum.Font.Gotham;
	desc.TextSize = 12;
	desc.TextColor3 = Color3.fromRGB(150, 150, 170);
	desc.Text = Config.HubDescription;
	desc.TextXAlignment = Enum.TextXAlignment.Left;
	local lbl = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\192\168\174\192\132\87\91\241\161", "\57\148\205\214\180\200\54"), main);
	lbl.Size = UDim2.new(1, -40, 0, 14);
	lbl.Position = UDim2.new(0, 20, 0, 82);
	lbl.BackgroundTransparency = 1;
	lbl.Font = Enum.Font.GothamMedium;
	lbl.TextSize = 11;
	lbl.TextColor3 = Color3.fromRGB(180, 180, 200);
	lbl.Text = LUAOBFUSACTOR_DECRYPT_STR_0("\54\212\18\29\66\55\189\6\1\87\82\214\16\13", "\22\114\157\85\84");
	lbl.TextXAlignment = Enum.TextXAlignment.Left;
	local inputFrame = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\226\217\18\201\88", "\200\164\171\115\164\61\150"), main);
	inputFrame.Size = UDim2.new(1, -40, 0, 40);
	inputFrame.Position = UDim2.new(0, 20, 0, 100);
	inputFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45);
	inputFrame.BorderSizePixel = 0;
	Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\139\221\32\74\145\176\241\17", "\227\222\148\99\37"), inputFrame).CornerRadius = UDim.new(0, 6);
	local iStroke = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\6\123\97\226\235\60\89\87", "\153\83\50\50\150"), inputFrame);
	iStroke.Color = Color3.fromRGB(60, 60, 80);
	iStroke.Thickness = 1;
	local input = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\105\115\107\8\81\164\85", "\45\61\22\19\124\19\203"), inputFrame);
	input.Size = UDim2.new(1, -20, 1, 0);
	input.Position = UDim2.new(0, 10, 0, 0);
	input.BackgroundTransparency = 1;
	input.Font = Enum.Font.Gotham;
	input.TextSize = 14;
	input.TextColor3 = Color3.fromRGB(255, 255, 255);
	input.PlaceholderText = LUAOBFUSACTOR_DECRYPT_STR_0("\249\42\53\205\79\72\129\249\42\64\205\58\72\129\140\42\53\205\58", "\217\161\114\109\149\98\16");
	input.PlaceholderColor3 = Color3.fromRGB(100, 100, 120);
	input.Text = "";
	input.ClearTextOnFocus = false;
	input.TextXAlignment = Enum.TextXAlignment.Left;
	local getKeyBtn = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\38\37\32\104\158\97\6\52\55\114", "\20\114\64\88\28\220"), main);
	getKeyBtn.Size = UDim2.new(1, -40, 0, 20);
	getKeyBtn.Position = UDim2.new(0, 20, 0, 146);
	getKeyBtn.BackgroundTransparency = 1;
	getKeyBtn.Font = Enum.Font.GothamMedium;
	getKeyBtn.TextSize = 12;
	getKeyBtn.TextColor3 = Color3.fromRGB(120, 160, 255);
	getKeyBtn.Text = "Não tem key?  →  Clique aqui para pegar uma";
	getKeyBtn.TextXAlignment = Enum.TextXAlignment.Left;
	getKeyBtn.AutoButtonColor = false;
	getKeyBtn.MouseEnter:Connect(function()
		getKeyBtn.TextColor3 = Color3.fromRGB(160, 190, 255);
	end);
	getKeyBtn.MouseLeave:Connect(function()
		getKeyBtn.TextColor3 = Color3.fromRGB(120, 160, 255);
	end);
	local btn = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\5\4\202\160\218\197\169\37\14\220", "\221\81\97\178\212\152\176"), main);
	btn.Size = UDim2.new(1, -40, 0, 42);
	btn.Position = UDim2.new(0, 20, 0, 174);
	btn.BackgroundColor3 = Color3.fromRGB(80, 120, 255);
	btn.BorderSizePixel = 0;
	btn.Font = Enum.Font.GothamBold;
	btn.TextSize = 15;
	btn.TextColor3 = Color3.fromRGB(255, 255, 255);
	btn.Text = LUAOBFUSACTOR_DECRYPT_STR_0("\251\194\47\210\60\228\196\60\201\90\230\194\36", "\122\173\135\125\155");
	btn.AutoButtonColor = false;
	Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\177\232\35\182\45\63\205\150", "\168\228\161\96\217\95\81"), btn).CornerRadius = UDim.new(0, 6);
	local status = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\239\212\54\72\3\86\217\212\34", "\55\187\177\78\60\79"), main);
	status.Size = UDim2.new(1, -40, 0, 18);
	status.Position = UDim2.new(0, 20, 0, 224);
	status.BackgroundTransparency = 1;
	status.Font = Enum.Font.Gotham;
	status.TextSize = 12;
	status.TextColor3 = Color3.fromRGB(150, 150, 170);
	status.Text = "";
	status.TextXAlignment = Enum.TextXAlignment.Left;
	status.TextWrapped = true;
	local foot = Instance.new(LUAOBFUSACTOR_DECRYPT_STR_0("\25\203\71\255\106\206\130\40\194", "\224\77\174\63\139\38\175"), main);
	foot.Size = UDim2.new(1, -40, 0, 12);
	foot.Position = UDim2.new(0, 20, 1, -22);
	foot.BackgroundTransparency = 1;
	foot.Font = Enum.Font.Gotham;
	foot.TextSize = 10;
	foot.TextColor3 = Color3.fromRGB(80, 80, 100);
	foot.Text = LUAOBFUSACTOR_DECRYPT_STR_0("\134\88\24", "\78\228\33\56") .. Config.HubName;
	foot.TextXAlignment = Enum.TextXAlignment.Left;
	local dragging, dragStart, startPos;
	main.InputBegan:Connect(function(i)
		if (i.UserInputType == Enum.UserInputType.MouseButton1) then
			dragging = true;
			dragStart = i.Position;
			startPos = main.Position;
		end
	end);
	UserInputService.InputChanged:Connect(function(i)
		if (dragging and (i.UserInputType == Enum.UserInputType.MouseMovement)) then
			local d = i.Position - dragStart;
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y);
		end
	end);
	UserInputService.InputEnded:Connect(function(i)
		if (i.UserInputType == Enum.UserInputType.MouseButton1) then
			dragging = false;
		end
	end);
	local function openURL(url)
		local clip = setclipboard or toclipboard;
		if clip then
			pcall(clip, url);
		end
		if openbrowser then
			pcall(openbrowser, url);
			return true;
		end
		if (syn and syn.openBrowser) then
			pcall(syn.openBrowser, url);
			return true;
		end
		return false;
	end
	getKeyBtn.MouseButton1Click:Connect(function()
		local opened = openURL(Config.GetKeyURL);
		if opened then
			status.Text = LUAOBFUSACTOR_DECRYPT_STR_0("\226\119\188\8\197\207\124\183\17\145\193\62\188\12\197\192\127\164\6\130\207\122\189\17\196", "\229\174\30\210\99");
			status.TextColor3 = Color3.fromRGB(100, 255, 100);
		else
			status.Text = LUAOBFUSACTOR_DECRYPT_STR_0("\55\228\136\90\173\62\54\11\228\135\85\226\124\121\56\226\138\84\173\51\54\91\227\135\71\232\58\56\31\226\148\31", "\89\123\141\230\49\141\93");
			status.TextColor3 = Color3.fromRGB(255, 200, 80);
		end
	end);
	return screenGui, input, btn, status;
end
local function loadMainScript()
	local ok, urlOrErr = cacheLink();
	if not ok then
		warn(LUAOBFUSACTOR_DECRYPT_STR_0("\200\90\243\21\35\83\224\101\243\1\45\10\198\67\218\86\80", "\42\147\17\150\108\112") .. tostring(urlOrErr));
		return false, urlOrErr;
	end
	local resp, err = safeRequest({[LUAOBFUSACTOR_DECRYPT_STR_0("\58\180\33", "\136\111\198\77\31\135")]=urlOrErr,[LUAOBFUSACTOR_DECRYPT_STR_0("\47\12\179\94\178\224", "\201\98\105\199\54\221\132\119")]=LUAOBFUSACTOR_DECRYPT_STR_0("\158\41\183", "\204\217\108\227\65\98\85")});
	if (not resp or (resp.StatusCode ~= 200)) then
		warn(LUAOBFUSACTOR_DECRYPT_STR_0("\101\232\240\252\31\217\77\215\240\232\17\128\122\204\226\235\32\207\95\199\175\165", "\160\62\163\149\133\76") .. tostring(err or (resp and resp.StatusCode)));
		return false, LUAOBFUSACTOR_DECRYPT_STR_0("\240\161\1\39\194\150\161\2\111\193\215\169\21\46\209\150\179\14\61\202\198\180", "\163\182\192\109\79");
	end
	local fn, compileErr = loadstring(resp.Body);
	if not fn then
		warn(LUAOBFUSACTOR_DECRYPT_STR_0("\15\13\5\217\198\45\53\20\197\248\9\102\35\207\248\36\47\12\197\175\116", "\149\84\70\96\160") .. tostring(compileErr));
		return false, LUAOBFUSACTOR_DECRYPT_STR_0("\29\20\31\226\120\7\2\173\59\9\0\253\49\10\12\255\120\21\14\255\49\22\25", "\141\88\102\109");
	end
	local okRun, runErr = pcall(fn);
	if not okRun then
		warn(LUAOBFUSACTOR_DECRYPT_STR_0("\136\120\207\105\41\36\70\213\182\94\247\48\40\40\91\155\243", "\161\211\51\170\16\122\93\53") .. tostring(runErr));
		return false, tostring(runErr);
	end
	return true;
end
local function start()
	local gui, input, btn, status = showLoginGui();
	local function setStatus(txt, color)
		status.Text = txt;
		status.TextColor3 = color;
	end
	local function setBtn(txt, color, active)
		btn.Text = txt;
		btn.BackgroundColor3 = color;
		btn.Active = active;
	end
	task.spawn(function()
		local saved = readKeyFromFile();
		if (saved and (#saved > 3)) then
			input.Text = saved;
			setStatus(LUAOBFUSACTOR_DECRYPT_STR_0("\205\171\160\33\253\167\177\41\245\170\189\104\240\171\171\104\232\175\190\62\250\224\252\102", "\72\155\206\210"), Color3.fromRGB(255, 200, 80));
			local ok, err = redeemKey(saved);
			if ok then
				setStatus("Key válida! Carregando...", Color3.fromRGB(100, 255, 100));
				task.wait(0.4);
				gui:Destroy();
				local loaded, loadErr = loadMainScript();
				if not loaded then
					start();
					warn(LUAOBFUSACTOR_DECRYPT_STR_0("\125\81\81\23\0\95\105\64\11\62\123\58", "\83\38\26\52\110") .. tostring(loadErr));
				end
			else
				setStatus(LUAOBFUSACTOR_DECRYPT_STR_0("\115\18\62\6\75\22\43\80\89\87\33\71\84\31\40\83\2\87", "\38\56\119\71") .. tostring(err), Color3.fromRGB(255, 100, 100));
			end
		end
	end);
	btn.MouseButton1Click:Connect(function()
		local key = (input.Text or ""):gsub(LUAOBFUSACTOR_DECRYPT_STR_0("\182\252\19", "\54\147\143\56\182\69"), "");
		if (#key < 4) then
			setStatus("Digite uma key válida", Color3.fromRGB(255, 100, 100));
			return;
		end
		setBtn(LUAOBFUSACTOR_DECRYPT_STR_0("\224\132\237\64\217\223\130\254\71\219\217\207\177\7", "\191\182\225\159\41"), Color3.fromRGB(60, 90, 200), false);
		setStatus(LUAOBFUSACTOR_DECRYPT_STR_0("\8\29\38\65\138\147\195\37\22\39\21\152\130\208\61\27\44\90\153\201\140\101", "\162\75\114\72\53\235\231"), Color3.fromRGB(255, 200, 80));
		task.spawn(function()
			local ok, err = redeemKey(key);
			if ok then
				setStatus(LUAOBFUSACTOR_DECRYPT_STR_0("\191\41\71\231\64\17\131\125\4\193\82\16\158\57\67\227\93\6\131\114\10\172", "\98\236\92\36\130\51"), Color3.fromRGB(100, 255, 100));
				setBtn(LUAOBFUSACTOR_DECRYPT_STR_0("\139\50\77", "\80\196\121\108\218\37\200\213"), Color3.fromRGB(60, 200, 80), false);
				task.wait(0.5);
				gui:Destroy();
				local loaded, loadErr = loadMainScript();
				if not loaded then
					start();
					warn(LUAOBFUSACTOR_DECRYPT_STR_0("\59\88\7\102\120\23\153\20\118\15\66\11", "\234\96\19\98\31\43\110") .. tostring(loadErr));
				end
			else
				setStatus(tostring(err), Color3.fromRGB(255, 100, 100));
				setBtn(LUAOBFUSACTOR_DECRYPT_STR_0("\48\58\96\238\138\91\168\39\45\18\236\137\75", "\235\102\127\50\167\204\18"), Color3.fromRGB(80, 120, 255), true);
			end
		end);
	end);
end
start();
