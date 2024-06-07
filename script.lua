--LUA SCRIPT--

--Patches GS at start up with various custom functions and configurations--

--=================================
--Global variables
--=================================

lua_idx                  = 6660 --  unique index
pwskill_mod136           = 1    -- use skills version 136

Rate                     = 0x08D6F89C --  Rate table (float ) -- 6 rates
Wallow                   = 0x094D3360 -- .bss:094D3360 _ZN11anti_wallow4listE punitive_param 4 dup(<0>)
Balance                  = 0x095E7B80 -- Balance table (480h) -- 11 classes (float, float[5])
FirsRun                  = 0x095E8000 -- Incast/recast table(60h) -- 11 classes(int,int)
Incast                   = 0x095E8060 -- Cast reduction table(30h) -- 11 classes(int)
IncastSkill              = 0x095E8090 -- Table of individual skills(370h) -- 110 skills(int,int)
IncastCooldown           = 0x095E8400 -- Skill Delay Table(50h) -- 10 cooldowns(int,int)
BugBless                 = 0x095E8450 -- BugBless Skill Inclusion Table by Class(30h) -- 11 classes(int,int)
BugBlessSkill            = 0x095E8480 -- Table of individual bug skills(380h) -- 112 skills(int,int)
Swap                     = 0x095E8800 -- Combat swap table(80h) -- 32 slots(int)
SwapCooldown             = 0x095E8880 -- SwapCooldown Table(50h) -- 10 cooldowns(int,int)
AutoSwapCooldown         = 0x095E88D0 -- AutoSwapCooldown Delay Table(50h) -- 10 cooldowns(int,int)
AutoSwap                 = 0x095E8920 -- AutoSwap Slot Table(110h) -- 32 cells(int,int)
AttackSpeed              = 0x095E8A30 -- Att Speed table with weapon types(A0h) -- 20 type, speed(int,int)
AttackSpeedGood          = 0x095E8AD0 -- Att Speed (Sage) table with weapon types(A0h) -- 20 type, speed(int,int)
AttackSpeedEvil          = 0x095E8B70 -- Att Speed (Demon) table with weapon types(A0h) -- 20 type, speed(int,int)
DistanceService          = 0x095E8C10 -- Table of distance services(60) -- 24 services(int)
g17Cooldown              = 0x095E8C70 -- Cannon Baffle Shuffle Table(50h) -- 10 Culldowns(int,int)
DistanceServiceWorld     = 0x095E8CC0 -- Table of locations where remote services are enabled(200h) -- 128 locations (int)
PetSummon                = 0x095E8EC0 -- Pet re-call table(10h) -- 4 values -- 4 parameters (int)
VipPickupWorld           = 0x095E8ED0 -- Table of locations where VIP loot collection is unavailable(200h) -- 128 locations (int)
FreeAmuletWorld          = 0x095E90D0 -- Table of locations in which hirks are infinite(200h) -- 128 locations (int)
FreeItems                = 0x095E92D0 -- Table of immutable items (200h) -- 128 items(int)
DummyItems               = 0x095E94D0 -- Resurrection Puppet Table (40h) -- 16 items (int)
ItemUseFunctions         = 0x095E9510 -- Table of functions when using the items (180h) -- 32 functions (int,offt,int)
SpeekerItems             = 0x095E9690 -- Horn table (40h) -- 16 items (int)
Speeker2Items            = 0x095E96D0 -- Table of mounts (40h) -- 16 items (int)
FreeAmulet               = 0x095E9710 -- Table of infinite amulets (40h) -- 16 items (int)
ItemDistableWorld        = 0x095E9750 -- Table of locations where genies don't work (200h) -- 128 locations (int)
OfflineCats              = 0x095E9950 -- Table of items for cats offline (40h) -- 16 items (int)



--=================================
--Program variables
--=================================

hw_limiter = 0x0 -- Table for restricting windows in locations

--=================================
--Features that can be used in LUA
--=================================
--void game__BroadcastChat(int roleid, char channel, const char * src)
--int game__GetWorldTag()
--int game__GetWorldIndex()
--void game__SetBlackHwid(const char hw)
--void game__ClearBlackHwid()

--=================================
--Maths Functions
--=================================

-- Get time of day
function get_time_dey()
    return int(os.time() / 86400)
end

function strtoint(inputstr)
    if inputstr == nil then
        return 0
    end
    return tonumber(inputstr)
end

-- Convert text to hex
function string.fromhex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

-- Convert hex to text
function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

-- Convert number to int
function int(numb)
    return math.floor(numb)
end

-- Get the date and time
function mydata()
    return os.date("%Y-%m-%d %H:%M:%S")
end

-- Write to log file
function mylogfunc(text)
    local outstr = mydata().." ["..game__GetWorldTag().."] "..text.."\n"
    local file = io.open("lualog.txt", "a")
    file:write(outstr)
    file:close()
    io.write(outstr)
end

-- Write to main world2 log file
function world2log(text)
    local outstr = mydata().." "..text.."\n"
    local file = io.open("../logs/world2.log", "a")
    file:write(outstr)
    file:close()
    io.write(outstr)
end

-- Writing to the log file
function funnytext(message)
    str = message
    as = {'��', '��', 'e', '��', '��', '��'}
    whereat = {'��', 'a', '��', 'a', 'o', 'e'}
    if #as == #whereat then
        for i=1,#as do
            str = str:gsub(as[i], whereat[i])
        end
    end
    return str
end

-- break the chat down into words
function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

-- Check table for the correct item
function check_true_item(item , items)
    if items[item] == nil then
        return 0
    end
    return items[item]
end

--=================================
--Patching Functions
--=================================

--Patching a table of 1 char.
function CharTable(pushd, value)
    game__PatchGS(pushd,"char",value)
    pushd = pushd + 1
    return pushd
end

--Patching a table of 1 short.
function ShortTable(pushd, value)
    game__PatchGS(pushd,"short",value)
    pushd = pushd + 2
    return pushd
end

--Patching a table of 1 int
function IntTable(pushd, value)
    game__PatchGS(pushd,"int",value)
    pushd = pushd + 4
    return pushd
end

--Patching a table of 1 float
function FloatTable(pushd, value)
    game__PatchGS(pushd,"float",value)
    pushd = pushd + 4
    return pushd
end

--Patching a table of 2 ints.
function IntIntTable(pushd, value1, value2)
    game__PatchGS(pushd,"int",value1)
    pushd = pushd + 4
    game__PatchGS(pushd,"int",value2)
    pushd = pushd + 4
    return pushd
end

--Patching a table of 2 floats
function FloatFloatTable(pushd, value1, value2)
    game__PatchGS(pushd,"float",value1)
    pushd = pushd + 4
    game__PatchGS(pushd,"float",value2)
    pushd = pushd + 4
    return pushd
end

-- XID ++
function HashIDX()
    lua_idx = lua_idx+1
    return lua_idx
end

--=================================
--Server Functions
--=================================

-- Class Balance Editor
function LUA_BALANCE_EDITOR_PATCHING()
    local xid_table = 96
    local buff = Balance
    local pushd = 0 -- float buff[4*2*12];

    -- [CLS::0] -------------- [BM Damage] -----------------------
    pushd = buff + xid_table * 0 -- (Physical, Magical) --
    pushd = FloatFloatTable(pushd,0.0,0.0) -- BM
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Wizard
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para xam?
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para druida
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para lobisomem
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para ladr?o
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para arqueiro
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para paladino
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para guarda
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para mestre
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para fantasma
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para ceifador

    -- [CLS::1] -------------- [Dano m��gico] -----------------------
    pushd = buff + xid_table * 1 -- (f��sica, m��gica) --
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para guerreiro
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para mago
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para xam?
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para druida
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para lobisomem
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para ladr?o
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para arqueiro
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para paladino
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para guarda
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para mestre
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para fantasma
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para ceifador

    -- [CLS::2] -------------- [Dano xam?] -----------------------
    pushd = buff + xid_table * 2 -- (f��sica, m��gica) --
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para guerreiro
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para mago
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para xam?
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para druida
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para lobisomem
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para ladr?o
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para arqueiro
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para paladino
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para guarda
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para mestre
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para fantasma
    pushd = FloatFloatTable(pushd,0.0,0.0) -- Para ceifador

        --[CLS::3]--------------[���ѧާѧ� �է��ڧէ�]---------------------
        pushd = buff + xid_table * 3   --(��ڧ�, �ާѧ�) --
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ӧѧ��
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާѧԧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ѧާѧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �է��ڧէ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ҧ����ߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ڧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ݧ��ߧڧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ����ѧا�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ٧�ѧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �اߧ֧��
        --[CLS::4]--------------[���ѧާѧ� ��ҧ����ߧ�]-------------------
        pushd = buff + xid_table * 4   --(��ڧ�, �ާѧ�) --
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ӧѧ��
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާѧԧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ѧާѧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �է��ڧէ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ҧ����ߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ڧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ݧ��ߧڧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ����ѧا�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ٧�ѧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �اߧ֧��
        --[CLS::5]--------------[���ѧާѧ� ��ҧڧۧ��]-----------------------
        pushd = buff + xid_table * 5   --(��ڧ�, �ާѧ�) --
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ӧѧ��
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާѧԧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ѧާѧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �է��ڧէ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ҧ����ߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ڧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ݧ��ߧڧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ����ѧا�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ٧�ѧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �اߧ֧��
        --[CLS::6]--------------[���ѧާѧ� �ݧ��ߧڧܧ�]--------------------
        pushd = buff + xid_table * 6   --(��ڧ�, �ާѧ�) --
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ӧѧ��
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާѧԧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ѧާѧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �է��ڧէ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ҧ����ߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ڧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ݧ��ߧڧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ����ѧا�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ٧�ѧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �اߧ֧��
        --[CLS::7]--------------[���ѧާѧ� �ا�֧��]----------------------
        pushd = buff + xid_table * 7   --(��ڧ�, �ާѧ�) --
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ӧѧ��
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާѧԧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ѧާѧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �է��ڧէ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ҧ����ߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ڧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ݧ��ߧڧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ����ѧا�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ٧�ѧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �اߧ֧��
        --[CLS::8]--------------[���ѧާѧ� ����ѧا�]-----------------------
        pushd = buff + xid_table * 8   --(��ڧ�, �ާѧ�) --
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ӧѧ��
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާѧԧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ѧާѧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �է��ڧէ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ҧ����ߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ڧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ݧ��ߧڧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ����ѧا�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ٧�ѧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �اߧ֧��
        --[CLS::9]--------------[���ѧާѧ� �ާڧ��ڧܧ�]-----------------------
        pushd = buff + xid_table * 9   --(��ڧ�, �ާѧ�) --
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ӧѧ��
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާѧԧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ѧާѧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �է��ڧէ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ҧ����ߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ڧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ݧ��ߧڧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ����ѧا�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ٧�ѧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �اߧ֧��
        --[CLS::10]--------------[���ѧާѧ� ���ڧ٧�ѧܧ�]-----------------------
        pushd = buff + xid_table * 10   --(��ڧ�, �ާѧ�) --
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ӧѧ��
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާѧԧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ѧާѧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �է��ڧէ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ҧ����ߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ڧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ݧ��ߧڧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ����ѧا�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ٧�ѧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �اߧ֧��
        --[CLS::11]--------------[���ѧާѧ� �اߧ֧��]-----------------------
        pushd = buff + xid_table * 11   --(��ڧ�, �ާѧ�) --
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ӧѧ��
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާѧԧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ѧާѧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �է��ڧէ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ҧ����ߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ��ڧߧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ݧ��ߧڧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ����ѧا�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �ާڧ���
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� ���ڧ٧�ѧܧ�
        pushd = FloatFloatTable(pushd,0.0,0.0) -- ���� �اߧ֧��

        mylogfunc("BALANCE_EDITOR_PATCHING: --OK-- ")
        return 0
end

--======================================================================================

-- Chanelling Time Editor
function LUA_INCAST_EDITOR()

    local pushd = 0

    -- Channeling Time and recast editor for each class
    pushd = FirsRun -- Incast::FirstRun(incast, recast)
    pushd = IntIntTable(pushd, 99, 90) -- CLS 0 ; guerreiro
    pushd = IntIntTable(pushd, 99, 90) -- CLS 1 ; mago
    pushd = IntIntTable(pushd, 99, 90) -- CLS 2 ; xam?
    pushd = IntIntTable(pushd, 99, 90) -- CLS 3 ; druida
    pushd = IntIntTable(pushd, 99, 90) -- CLS 4 ; lobisomem
    pushd = IntIntTable(pushd, 99, 90) -- CLS 5 ; ladr?o
    pushd = IntIntTable(pushd, 99, 90) -- CLS 6 ; arqueiro
    pushd = IntIntTable(pushd, 99, 90) -- CLS 7 ; paladino
    pushd = IntIntTable(pushd, 99, 90) -- CLS 8 ; guarda
    pushd = IntIntTable(pushd, 99, 90) -- CLS 9 ; mestre

    --Editor of all skils globally for each class at -99% chanelling time
    pushd = Incast -- Incast::Editor(Channelling time acceleration from 0 to 32 (0 - default, 32+ incast as in 136))
    pushd = IntTable(pushd, 0) -- CLS 0 ; guerreiro
    pushd = IntTable(pushd, 0) -- CLS 1 ; mago
    pushd = IntTable(pushd, 0) -- CLS 2 ; xam?
    pushd = IntTable(pushd, 0) -- CLS 3 ; druida
    pushd = IntTable(pushd, 0) -- CLS 4 ; lobisomem
    pushd = IntTable(pushd, 0) -- CLS 5 ; ladr?o
    pushd = IntTable(pushd, 0) -- CLS 6 ; arqueiro
    pushd = IntTable(pushd, 0) -- CLS 7 ; paladino
    pushd = IntTable(pushd, 0) -- CLS 8 ; guarda
    pushd = IntTable(pushd, 0) -- CLS 9 ; mestre

    --Editor of individual skills for each class at -99% chanelling time
    pushd = IncastSkill -- Skill::IncastTable(Skill ID, Channelling time acceleration from 0 to 32 (0 - default, 32+ incast as in 136))
    pushd = IntIntTable(pushd, 99, 0) --Wizard: Mountain 2 spark skill
    pushd = IntIntTable(pushd, 484, 0) --Wizard: Mountain 2 spark skill [Sage]
    pushd = IntIntTable(pushd, 485, 0) --Wizard: Mountain 2 spark skill [Demon]

    -- Auto Clicker protection
    pushd = IncastCooldown -- Skill::LockTimer
    pushd = IntIntTable(pushd, lua_idx, 400) HashIDX()
    pushd = IntIntTable(pushd, lua_idx, 300) HashIDX()
    pushd = IntIntTable(pushd, lua_idx, 200) HashIDX()
    pushd = IntIntTable(pushd, lua_idx, 100) HashIDX()

    mylogfunc("Patching Chanelling Times OK")
    return 0
end

--Bug Skill Editor
function LUA_BUG_SKILL_EDITOR()

    local pushd = 0

    --Editor of all skils globally for each class
    pushd = BugBless -- BugSkill::Editor(0 off - 1 on)
    pushd = IntTable(pushd, 1) -- CLS == 0 ; Blademaster
    pushd = IntTable(pushd, 0) -- CLS == 1 ; Wizard
    pushd = IntTable(pushd, 0) -- CLS == 2 ; xam?
    pushd = IntTable(pushd, 0) -- CLS == 3 ; druida
    pushd = IntTable(pushd, 0) -- CLS == 4 ; lobisomem
    pushd = IntTable(pushd, 0) -- CLS == 5 ; ladr?o
    pushd = IntTable(pushd, 0) -- CLS == 6 ; arqueiro
    pushd = IntTable(pushd, 0) -- CLS == 7 ; paladino
    pushd = IntTable(pushd, 0) -- CLS == 8 ; guarda
    pushd = IntTable(pushd, 0) -- CLS == 9 ; mestre

    --Editor of individual skils
    pushd = BugBlessSkill -- BugSkill::Table(skill ID, 0 off - 1 on)
    pushd = IntIntTable(pushd, 58, 0) -- BM: Soaring Dragon
    pushd = IntIntTable(pushd, 59, 0) -- BM: Tigers Leap
    pushd = IntIntTable(pushd, 100, 0) -- Wiz: Land shift
    pushd = IntIntTable(pushd, 478, 0) -- Wiz: Land shift (Sage)
    pushd = IntIntTable(pushd, 479, 0) -- Wiz: Land shift (Demon)

    mylogfunc("Patching bug_skill OK")
    return 0
end

-- Item Exchange Editor
function LUA_SWAP_ITEM_EDITOR()

    local pushd = 0
    local swap_item = 50960 -- Item ID for automatic exchange

    IntTable(0x095E033A, swap_item)
    IntTable(0x095E9528, swap_item)

    -- List of (PWA) equipment positions that cannot be used in combat
    -- 0 - can, 1 - can't (Genie), 2 - can't in any situation (Charm)
    pushd = Swap
    pushd = IntTable(pushd, 0) -- Weapon
    pushd = IntTable(pushd, 0) -- Helmet
    pushd = IntTable(pushd, 0) -- Necklace
    pushd = IntTable(pushd, 0) -- Cape
    pushd = IntTable(pushd, 0) -- Armour
    pushd = IntTable(pushd, 0) -- Belt
    pushd = IntTable(pushd, 0) -- Legs
    pushd = IntTable(pushd, 0) -- Boots
    pushd = IntTable(pushd, 0) -- Arms
    pushd = IntTable(pushd, 0) -- Ring 1
    pushd = IntTable(pushd, 0) -- Ring 2
    pushd = IntTable(pushd, 0) -- Arrows
    pushd = IntTable(pushd, 0) -- Flyer
    pushd = IntTable(pushd, 0) -- Fashion Top
    pushd = IntTable(pushd, 0) -- Fashion Legs
    pushd = IntTable(pushd, 0) -- Fashion Boots
    pushd = IntTable(pushd, 0) -- Fashion Gloves
    pushd = IntTable(pushd, 0) -- Attack Charms (??)
    pushd = IntTable(pushd, 0) -- Treaty (??)
    pushd = IntTable(pushd, 0) -- Smileys
    pushd = IntTable(pushd, 0) -- HP Charm
    pushd = IntTable(pushd, 0) -- MP Charm
    pushd = IntTable(pushd, 0) -- Tome (??)
    pushd = IntTable(pushd, 1) -- Genie
    pushd = IntTable(pushd, 0) -- Cat Shop License
    pushd = IntTable(pushd, 0) -- Fashion Head
    pushd = IntTable(pushd, 0) -- Alliance Diploma
    pushd = IntTable(pushd, 0) -- Warrior Seal 1
    pushd = IntTable(pushd, 0) -- Warrior Seal 2
    pushd = IntTable(pushd, 0) -- Fashion Wep (??)
    pushd = IntTable(pushd, 0) -- ???
    pushd = IntTable(pushd, 0) -- ???
    pushd = IntTable(pushd, 0) -- ???

        --Table of delays from swap flooding (protection from third-party flooding)
    pushd = SwapCooldown
    pushd = IntIntTable(pushd, lua_idx, 800) HashIDX()
    pushd = IntIntTable(pushd, lua_idx, 600) HashIDX()
    pushd = IntIntTable(pushd, lua_idx, 400) HashIDX()
    pushd = IntIntTable(pushd, lua_idx, 200) HashIDX()

    -- Autoswap Slot Table (110h) -- 32 cells(int, int)
    pushd = AutoSwap
    pushd = IntTable(pushd, 5)
    pushd = IntIntTable(pushd, 0, 0) -- Armour
    pushd = IntIntTable(pushd, 2, 9) -- Left Ring
    pushd = IntIntTable(pushd, 3, 2) -- Necklace
    pushd = IntIntTable(pushd, 4, 5) -- Belt
    pushd = IntIntTable(pushd, 5, 4) -- Armour

    --Table of delays from autoswap flooding
    pushd = AutoSwapCooldown
    pushd = IntIntTable(pushd, lua_idx, 4000) HashIDX()
    pushd = IntIntTable(pushd, lua_idx, 3000) HashIDX()
    pushd = IntIntTable(pushd, lua_idx, 2000) HashIDX()
    pushd = IntIntTable(pushd, lua_idx, 1000) HashIDX()

    mylogfunc("swap_editor OK")
    return 0
end

-- Attack speed editor with different cultivations and weapon types
function LUA_ATTACK_SPEED_EDITOR()

    local pushd = 0

    -- Attack speed for cultivation 0 - 8 (lvl 0-79) (for example: 4 = 5.00 ; 5 = 4.00 ; 6 = 3.33) and so on
    pushd = AttackSpeed -- AttackSpeed::Editor(Weapon type, attack speed)
    pushd = IntIntTable(pushd, 1, 4) -- Sword
    pushd = IntIntTable(pushd, 5, 4) -- Spears
    pushd = IntIntTable(pushd, 9, 4) -- Axes
    pushd = IntIntTable(pushd, 13, 4) -- Ranged Weapons
    pushd = IntIntTable(pushd, 182, 4) -- Fists
    pushd = IntIntTable(pushd, 291, 4) -- Whips
    pushd = IntIntTable(pushd, 292, 4) -- Magic Weapons
    pushd = IntIntTable(pushd, 23749, 4) -- Daggers
    pushd = IntIntTable(pushd, 25333, 4) -- Spheres
    pushd = IntIntTable(pushd, 44878, 4) -- Sabres
    pushd = IntIntTable(pushd, 44879, 4) -- Scythes
    pushd = IntIntTable(pushd, 59830, 4) -- Shields
    pushd = IntIntTable(pushd, 59831, 4) -- Cannons

    -- Attack speed for cultivation 20 - 22 (Sage 89-100) (for example: 4 = 5.00 ; 5 = 4.00 ; 6 = 3.33) and so on
    pushd = AttackSpeedGood -- AttackSpeed::Editor(Weapon type, attack speed)
    pushd = IntIntTable(pushd, 1, 4) -- Sword
    pushd = IntIntTable(pushd, 5, 4) -- Spears
    pushd = IntIntTable(pushd, 9, 4) -- Axes
    pushd = IntIntTable(pushd, 13, 4) -- Ranged Weapons
    pushd = IntIntTable(pushd, 182, 4) -- Fists
    pushd = IntIntTable(pushd, 291, 4) -- Whips
    pushd = IntIntTable(pushd, 292, 4) -- Magic Weapons
    pushd = IntIntTable(pushd, 23749, 4) -- Daggers
    pushd = IntIntTable(pushd, 25333, 4) -- Spheres
    pushd = IntIntTable(pushd, 44878, 4) -- Sabres
    pushd = IntIntTable(pushd, 44879, 4) -- Scythes
    pushd = IntIntTable(pushd, 59830, 4) -- Shields
    pushd = IntIntTable(pushd, 59831, 4) -- Cannons

    -- Attack speed for cultivation 30 - 32 (Demon 89-100) (for example: 4 = 5.00 ; 5 = 4.00 ; 6 = 3.33) and so on
    pushd = AttackSpeedEvil -- AttackSpeed::Editor(Weapon type, attack speed)
    pushd = IntIntTable(pushd, 1, 4) -- Sword
    pushd = IntIntTable(pushd, 5, 4) -- Spears
    pushd = IntIntTable(pushd, 9, 4) -- Axes
    pushd = IntIntTable(pushd, 13, 4) -- Ranged Weapons
    pushd = IntIntTable(pushd, 182, 4) -- Fists
    pushd = IntIntTable(pushd, 291, 4) -- Whips
    pushd = IntIntTable(pushd, 292, 4) -- Magic Weapons
    pushd = IntIntTable(pushd, 23749, 4) -- Daggers
    pushd = IntIntTable(pushd, 25333, 4) -- Spheres
    pushd = IntIntTable(pushd, 44878, 4) -- Sabres
    pushd = IntIntTable(pushd, 44879, 4) -- Scythes
    pushd = IntIntTable(pushd, 59830, 4) -- Shields
    pushd = IntIntTable(pushd, 59831, 4) -- Cannons

    mylogfunc("Patching attack_speed OK")
    return 0
end


--======================================================================================

--Distance Services Editor
function LUA_DISTANCE_SERVICE_TYPE()

    local pushd = 0
    pushd = DistanceService

    --pushd = IntTable(pushd,1 ) --purchase of items (different handler)
    pushd = IntTable(pushd,2 ) -- Sell Items
    pushd = IntTable(pushd,3 ) -- Repair Items
    pushd = IntTable(pushd,9 ) -- Learn Skills
    --pushd = IntTable(pushd,35) -- Refine Gear
    --pushd = IntTable(pushd,10) -- Imbue Socket Gems
    --pushd = IntTable(pushd,11) -- Purge Socket Gems
    --pushd = IntTable(pushd,47) -- Add Socket
    pushd = IntTable(pushd,14) -- Bank Password
    pushd = IntTable(pushd,15) -- Bank
    pushd = IntTable(pushd,25) -- Mail
    --pushd = IntTable(pushd,28) -- Pet Incubation
    --pushd = IntTable(pushd,29) -- Pet Egg Restore
    --pushd = IntTable(pushd,36) -- Change pet name
    --pushd = IntTable(pushd,69) -- Remote engraving

    pushd = IntTable(pushd,0) -- Last Array Element
    mylogfunc("LUA_DISTANCE_SERVICE_TYPE OK!")
    return 1
end

--======================================================================================

--Locations Remote Banking/Mailing/Shop/Repair etc. Are Allowed
function LUA_DISTANCE_SERVICE_TAG()

    local pushd = 0
    pushd = DistanceServiceWorld

    pushd = IntTable(pushd,1  ) -- Open World
    -- pushd = IntTable(pushd,101) -- [Event] City of Abominations
    pushd = IntTable(pushd,102) -- Secret Passage
    pushd = IntTable(pushd,105) -- [FB19] Firecrag Grotto
    pushd = IntTable(pushd,106) -- [FB19] Den of Rabid Wolves
    pushd = IntTable(pushd,107) -- [FB19] Cave of the Vicious
    pushd = IntTable(pushd,108) -- [FB29] Hall of Deception
    pushd = IntTable(pushd,109) -- [FB39] Gate of Delirium
    pushd = IntTable(pushd,110) -- [FB51] Secret Frostcover Grounds
    pushd = IntTable(pushd,111) -- [FB59] Valley of Disaster
    -- pushd = IntTable(pushd,112) -- [Event] Forest Ruins
    pushd = IntTable(pushd,113) -- Cave of Sadistic Glee
    pushd = IntTable(pushd,114) -- [FB69] Wraithgate
    pushd = IntTable(pushd,115) -- [FB79] Hallucinatory Trench
    pushd = IntTable(pushd,116) -- [FB89] Eden
    pushd = IntTable(pushd,117) -- [FB89] Brimstone Pit
    -- pushd = IntTable(pushd,118) -- [Event] Dragon Temple
    pushd = IntTable(pushd,119) -- Nightscream Island
    -- pushd = IntTable(pushd,120) -- [Event] Snake Isle
    pushd = IntTable(pushd,121) -- Lothranis (Heaven World)
    pushd = IntTable(pushd,122) -- Momaganon (Hell World)
    pushd = IntTable(pushd,123) -- [FB99] Seat of Torment
    pushd = IntTable(pushd,124) -- [FB99] Abaddon
    pushd = IntTable(pushd,125) -- Warsong City
    pushd = IntTable(pushd,126) -- Nirvana Palace
    pushd = IntTable(pushd,127) -- Lunar Glade
    -- pushd = IntTable(pushd,128) -- GV
    pushd = IntTable(pushd,129) -- FC
    pushd = IntTable(pushd,131) -- TT
    pushd = IntTable(pushd,132) -- Cube of Fate
    pushd = IntTable(pushd,133) -- Chrono World 1-4
    -- pushd = IntTable(pushd,134) -- [Marriage] Perfect Chapel
    pushd = IntTable(pushd,135) -- Guild Base
    pushd = IntTable(pushd,138) -- PV
    -- pushd = IntTable(pushd,143) -- NW Strategic Map
    -- pushd = IntTable(pushd,144) -- NW Capture The Flag
    -- pushd = IntTable(pushd,145) -- NW Tower Defense
    -- pushd = IntTable(pushd,146) -- NW Crystal Capture
    -- pushd = IntTable(pushd,150) -- Realm of Reflection
    pushd = IntTable(pushd,161) -- Celestial Vale (Starter Zone)
    pushd = IntTable(pushd,169) -- Lightsail Cave
    pushd = IntTable(pushd,170) -- Cube of Fate (50-60)
    -- pushd = IntTable(pushd,177) -- PvP Tournament (Tues?)
    pushd = IntTable(pushd,180) -- Cloudtop Sanctuary
    pushd = IntTable(pushd,204) -- Archosaur Arena
    pushd = IntTable(pushd,214) -- Quicksand Maze
    -- pushd = IntTable(pushd,230) -- TW T-3 PvP
    -- pushd = IntTable(pushd,231) -- TW T-3 PvE
    -- pushd = IntTable(pushd,232) -- TW T-2 PvP
    -- pushd = IntTable(pushd,233) -- TW T-2 PvE
    -- pushd = IntTable(pushd,234) -- TW T-1 PvP
    -- pushd = IntTable(pushd,235) -- TW T-1 PvE

    pushd = IntTable(pushd,0  ) -- Last Array Element
    mylogfunc("LUA_DISTANCE_SERVICE_TAG OK!")
    return 1
end

--======================================================================================

--editor of hardware restrictions on sites
function LUA_HWID_TAG_LIMITER()

    local pushd = 0
    pushd = hw_limiter

    -- pushd = IntIntTable(pushd,1,1) -- Open World <-- Doesnt Work
    -- pushd = IntIntTable(pushd,101,1) -- [Event] City of Abominations
    -- pushd = IntIntTable(pushd,102,1) -- Secret Passage
    -- pushd = IntIntTable(pushd,105,1) -- [FB19] Firecrag Grotto
    -- pushd = IntIntTable(pushd,106,1) -- [FB19] Den of Rabid Wolves
    -- pushd = IntIntTable(pushd,107,1) -- [FB19] Cave of the Vicious
    -- pushd = IntIntTable(pushd,108,1) -- [FB29] Hall of Deception
    -- pushd = IntIntTable(pushd,109,1) -- [FB39] Gate of Delirium
    -- pushd = IntIntTable(pushd,110,1) -- [FB51] Secret Frostcover Grounds
    -- pushd = IntIntTable(pushd,111,1) -- [FB59] Valley of Disaster <-- up to here should work
    -- pushd = IntIntTable(pushd,112,1) -- [Event] Forest Ruins
    -- pushd = IntIntTable(pushd,113,1) -- Cave of Sadistic Glee
    -- pushd = IntIntTable(pushd,114,1) -- [FB69] Wraithgate
    -- pushd = IntIntTable(pushd,115,1) -- [FB79] Hallucinatory Trench
    -- pushd = IntIntTable(pushd,116,1) -- [FB89] Eden
    -- pushd = IntIntTable(pushd,117,1) -- [FB89] Brimstone Pit
    -- pushd = IntIntTable(pushd,118,1) -- [Event] Dragon Temple
    -- pushd = IntIntTable(pushd,119,1) -- Nightscream Island
    -- pushd = IntIntTable(pushd,120,1) -- [Event] Snake Isle
    -- pushd = IntIntTable(pushd,121,1) -- Lothranis (Heaven World)
    -- pushd = IntIntTable(pushd,122,1) -- Momaganon (Hell World)
    -- pushd = IntIntTable(pushd,123,1) -- [FB99] Seat of Torment
    -- pushd = IntIntTable(pushd,124,1) -- [FB99] Abaddon
    -- pushd = IntIntTable(pushd,125,1) -- Warsong City
    pushd = IntIntTable(pushd,126,2) -- Nirvana Palace
    -- pushd = IntIntTable(pushd,127,1) -- Lunar Glade
    pushd = IntIntTable(pushd,128,2) -- GV
    -- pushd = IntIntTable(pushd,129,1) -- FC -- Up to here works
    -- pushd = IntIntTable(pushd,131,1) -- TT
    -- pushd = IntIntTable(pushd,132,1) -- Cube of Fate
    -- pushd = IntIntTable(pushd,133,1) -- Chrono World 1-4
    -- pushd = IntIntTable(pushd,134,1) -- [Marriage] Perfect Chapel
    -- pushd = IntIntTable(pushd,135,1) -- Guild Base
    -- pushd = IntIntTable(pushd,138,1) -- PV
    pushd = IntIntTable(pushd,143,1) -- NW Strategic Map
    pushd = IntIntTable(pushd,144,1) -- NW Capture The Flag
    pushd = IntIntTable(pushd,145,1) -- NW Tower Defense
    pushd = IntIntTable(pushd,146,1) -- NW Crystal Capture
    -- pushd = IntIntTable(pushd,150,1) -- Realm of Reflection
    -- pushd = IntIntTable(pushd,161,1) -- Celestial Vale (Starter Zone)
    -- pushd = IntIntTable(pushd,169,1) -- Lightsail Cave
    -- pushd = IntIntTable(pushd,170,1) -- Cube of Fate (50-60)
    -- pushd = IntIntTable(pushd,177,1) -- PvP Tournament (Tues?)
    -- pushd = IntIntTable(pushd,180,1) -- Cloudtop Sanctuary
    pushd = IntIntTable(pushd,204,1) -- Archosaur Arena
    -- pushd = IntIntTable(pushd,214,1) -- Quicksand Maze
    -- pushd = IntIntTable(pushd,230,1) -- TW T-3 PvP
    -- pushd = IntIntTable(pushd,231,1) -- TW T-3 PvE
    -- pushd = IntIntTable(pushd,232,1) -- TW T-2 PvP
    -- pushd = IntIntTable(pushd,233,1) -- TW T-2 PvE
    -- pushd = IntIntTable(pushd,234,1) -- TW T-1 PvP
    -- pushd = IntIntTable(pushd,235,1) -- TW T-1 PvE

    pushd = IntIntTable(pushd,0  ,0) -- Last element of Array
    mylogfunc("LUA_HWID_TAG_LIMITER OK!")
    return 0
end


--======================================================================================

function LUA_BLACKLIST_EDITOR()

        game__ClearBlackHwid()
        game__SetBlackHwid("42945378002703")
        -- game__SetBlackHwid("-6242914837089791842")
        mylogfunc("ADD_BLACK_HWID: --OK-- ")

end

function LUA_RATE_PATCH( _tag , _exp , _sp, _item, _money, _task_exp, _task_sp, _task_money  )

    pushd = Wallow -- .bss:094D3360 _ZN11anti_wallow4listE punitive_param 4 dup(<0>)
    if ( game__GetWorldTag() == _tag ) then

        --pushd = pushd+4 -- punitive_param 0 active
        pushd = IntTable(pushd,1) --XP
        pushd = FloatTable(pushd,_exp) --XP
        pushd = FloatTable(pushd,_sp) --Spirit
        pushd = FloatTable(pushd,_item) --Drops
        pushd = FloatTable(pushd,_money) --Coin
        pushd = FloatTable(pushd,_task_exp) --Quest XP
        pushd = FloatTable(pushd,_task_sp) --Quest Spirit
        pushd = FloatTable(pushd,_task_money) --Quest Coin

        --pushd = pushd+4 -- punitive_param 1 active
        pushd = IntTable(pushd,1) --XP
        pushd = FloatTable(pushd,_exp) --XP
        pushd = FloatTable(pushd,_sp) --Spirit
        pushd = FloatTable(pushd,_item) --Drops
        pushd = FloatTable(pushd,_money) --Coin
        pushd = FloatTable(pushd,_task_exp) --Quest XP
        pushd = FloatTable(pushd,_task_sp) --Quest Spirit
        pushd = FloatTable(pushd,_task_money) --Quest Coin

        --pushd = pushd+4 -- punitive_param 2 active
        pushd = IntTable(pushd,1) --XP
        pushd = FloatTable(pushd,_exp) --XP
        pushd = FloatTable(pushd,_sp) --Spirit
        pushd = FloatTable(pushd,_item) --Drops
        pushd = FloatTable(pushd,_money) --Coin
        pushd = FloatTable(pushd,_task_exp) --Quest XP
        pushd = FloatTable(pushd,_task_sp) --Quest Spirit
        pushd = FloatTable(pushd,_task_money) --Quest Coin

        --pushd = pushd+4 -- punitive_param 3 active
        pushd = IntTable(pushd,1) --XP
        pushd = FloatTable(pushd,_exp) --XP
        pushd = FloatTable(pushd,_sp) --Spirit
        pushd = FloatTable(pushd,_item) --Drops
        pushd = FloatTable(pushd,_money) --Coin
        pushd = FloatTable(pushd,_task_exp) --Quest XP
        pushd = FloatTable(pushd,_task_sp) --Quest Spirit
        pushd = FloatTable(pushd,_task_money) --Quest Coin
    end

end

function LUA_RATE_TAGS()

    -- Set custom server rates within TT
    LUA_RATE_PATCH
    (
        131, --Location Tag (131 equates to TT Map is31)
        1.0, --XP Rate
        1.0, --Spirit Rate
        1.0, --Item Drop Rate
        1.0, --Money Drop Rate
        1.0, --Quest XP Multiplier
        1.0, --Quest Spirit Multiplier
        1.0  --Quest Money Multiplier
    )

    LUA_RATE_PATCH
    (
        161, --Celestial Vale
        1.0, --XP Rate
        1.0, --Spirit Rate
        1.0, --Item Drop Rate
        1.0, --Money Drop Rate
        1.0, --Quest XP Multiplier
        1.0, --Quest Spirit Multiplier
        1.0  --Quest Money Multiplier
    )


end

--======================================================================================

function LUA_OTHER_EDITOR()

    local pushd = 0

        -- Debug Password
    IntTable(0x095E0B7C,********************)

    -- Max Squad Size
    local team_max_members = 9 -- Allow 10 Man Squads
    CharTable(0x0818831B,team_max_members)
    CharTable(0x08187860,team_max_members)
    CharTable(0x081876C3,team_max_members)
    CharTable(0x08186E95,team_max_members)

    -- Teleport Stone Cooldown Time
    IntTable(0x082ED42B,500) --Time in milliseconds

    -- Auction House Time Length
        IntTable(0x083C09C6,3600*80 ) -- 80 hours
        IntTable(0x083C09D9,3600*160) -- 160 hours
        IntTable(0x083C09EC,3600*240) -- 240 hours

    --Level PvP Is Active
    CharTable(0x0809F460, 29) -- Level 1
    CharTable(0x080A0A4B, 29) -- Level 1

    --Maximum Soulforce
    IntTable(0x095E0A1A,35000)
    IntTable(0x095E0A21,35000)

    --Spirit
    IntTable(0x095E1FEC,1) --limit - 1 yes , 0 no
    IntTable(0x095E1FF0,0) --Maximum Spirit

    --Battle Spirit
    IntTable(0x095E1EE4,1) --limit - 1 yes , 0 no
    IntTable(0x095E1EE8,0) --Maximum Battle Spirit (I think this means New PW Spirit which gives you att/def lvls?)

    --Demand the removal of the pet
    IntTable(0x095E8EC0,0) --1 yes; 0 no

    -- Meridian
    IntTable(0x095E1FB0,0) -- number of attempts per day
    IntTable(0x095E1FB4,0) -- maximum number of attempts

    --Delete meridians
    ShortTable(0x0821951D,0x9090)
    ShortTable(0x0821928D,0x9090)

    --Remove patrol logins on the database.
    ShortTable(0x080BB0A0,0x9090)

    --Remove Sign In Calender Feature Completely
    --CharTable(0x080C393C,0xC3)
    --CharTable(0x080C3984,0xC3)

    --Time to leave Morai factions
    IntTable(0x080B7506,60) --1 Time
    IntTable(0x080B7524,60) --Subsequent Times

    -- Delete vip services
    --IntTable(0x080CA390,2210644017) --check always returns 0

    --Remove Safety Lock Feature Completely
    IntTable(0x08061EF2,12828721)

    --Remove luck bonus
    CharTable(0x0808D37A,0xC3)
    CharTable(0x0808D3FE,0xC3)
    FloatTable(0x08D54DD4,1.0)
    CharTable(0x080FE132,0xEB)

    --Chi Per Second During Meditation
    IntTable(0x095E0A95,399)

    --How long does TP stone not work after digging?
    IntTable(0x095E08D2,1000)

    --Fix the pets on the bumps
    IntTable(0x083A1CB5,1)

    --Pick Up All
    IntTable(0x095E1F20,1) --0 for VIP status, 1 for item
    IntTable(0x095E1F24,60000) --ID of Pick Up All Item

    local elflvlup_item = 64947 --item ID for Genie level up
    IntTable(0x095E9510,elflvlup_item)
    IntTable(0x095E168A,elflvlup_item)

    -- delay between weapon buffs 155+
    --IntIntTable(g17Cooldown, lua_idx, 30000) HashIDX() --milliseconds delay

    -- Server Rates
    pushd = Rate
    pushd = FloatTable(pushd,1.0) --XP
    pushd = FloatTable(pushd,2.0) --Spirit
    pushd = FloatTable(pushd,1.0) --Drops
    pushd = FloatTable(pushd,2.0) --Coins
    pushd = FloatTable(pushd,3.0) --Quests XP
    pushd = FloatTable(pushd,3.0) --Quests SP
    pushd = FloatTable(pushd,3.0) --Mission Coins

    --Locations where bulk item collection is disabled
    --pushd = VipPickupWorld
    --pushd = IntTable(pushd,201)    --GM Arena -- Asuras

     --Table of places with infinite Charms
    pushd = FreeAmuletWorld
    pushd = IntTable(pushd,143)    -- a43 - Hall of the Five Emperors(The main location of the Battle of Dynasties)
    pushd = IntTable(pushd,144) -- a44 - Nation War "Capture the Flag".
    pushd = IntTable(pushd,145) -- a45 - Nation War "Battle for Crystals"
    pushd = IntTable(pushd,146) -- a46 - Nation War "Bridge Battle"
    pushd = IntTable(pushd,147) -- a47 - Battle of the Catapults

    --Items that are not consumed when used
    pushd = FreeItems
    pushd = IntTable(pushd,51274) --Unlimited Teleport 7d/30d
    pushd = IntTable(pushd,64946) --Infinite Map of Life
    pushd = IntTable(pushd,64950) --Infinite Telecoustic
    pushd = IntTable(pushd,64951) --Infinite Horn

    --Items - Guardian Scrolls
    pushd = DummyItems
    pushd = IntTable(pushd,64946)
    pushd = IntTable(pushd,31878)
    pushd = IntTable(pushd,12361)
    pushd = IntTable(pushd,36309)

    --Items - Telecoustics
    pushd = SpeekerItems
    pushd = IntTable(pushd,64950)
    pushd = IntTable(pushd,12979)
    pushd = IntTable(pushd,36092)

    --Itens - Horns
    pushd = Speeker2Items
    pushd = IntTable(pushd,64951)
    pushd = IntTable(pushd,27728)
    pushd = IntTable(pushd,27729)

    --Infinite Charms
    pushd = FreeAmulet
    pushd = IntTable(pushd,64952) --Infinite HP Charms (?)
    pushd = IntTable(pushd,64953) --Infinite MP Charms (?)

    --Item IDs in Inventory that allow user to use Offline Catshop
    pushd = OfflineCats
    pushd = IntTable(pushd,51272) --Offline Cat 7d
    pushd = IntTable(pushd,51273) --Offline Cat 30d

    mylogfunc("LUA_OTHER_EDITOR: --OK-- ")
end

--======================================================================================
--EVENTS AND FUNCTIONS
--======================================================================================

--Reload the Lua file
function EventOnReloadScript()

    LUA_BALANCE_EDITOR_PATCHING()
    LUA_INCAST_EDITOR()
    LUA_BUG_SKILL_EDITOR()
    LUA_SWAP_ITEM_EDITOR()
    LUA_ATTACK_SPEED_EDITOR()
    LUA_DISTANCE_SERVICE_TYPE()
    LUA_DISTANCE_SERVICE_TAG()
    LUA_HWID_TAG_LIMITER()
    LUA_BLACKLIST_EDITOR()
    LUA_OTHER_EDITOR()
    LUA_RATE_TAGS()

    mylogfunc("EventOnReloadScript: --OK-- ")

end

--======================================================================================

--Patch Lua Code into GS startup
function EventOnBeforeStartGS()

    LUA_BALANCE_EDITOR_PATCHING()
    LUA_INCAST_EDITOR()
    LUA_BUG_SKILL_EDITOR()
    LUA_SWAP_ITEM_EDITOR()
    LUA_ATTACK_SPEED_EDITOR()
    LUA_DISTANCE_SERVICE_TYPE()
    LUA_DISTANCE_SERVICE_TAG()
    LUA_HWID_TAG_LIMITER()
    LUA_BLACKLIST_EDITOR()
    LUA_OTHER_EDITOR()

    mylogfunc("EventOnBeforeStartGS: --OK-- ")

end

--======================================================================================

--Patch Lua Code after GS has started
function EventOnInitWorld()

    local pushd = 0
    LUA_RATE_TAGS()

    mylogfunc("EventOnInitWorld: --OK-- ")

end

--======================================================================================

function EventPlayerSetHwid(roleid, hw)
    mylogfunc("EventOnBeforeStartGS: roleid = "..int(roleid)..", hwid = "..int(hw))
    -- world2log("Ubuntu-2004-focal-amd64-base gamed: info : ����"..int(roleid).."��"..hw)
    world2log("[Vex] Character Logged In - Role_ID="..int(roleid).." Hardware_ID="..hw)
end
