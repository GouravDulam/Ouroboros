-- ============================================================
-- OUROBOROS — HARD PROGRAMMING PUZZLE REPLACEMENT
-- Brutally hard C + Python + Systems Tech
-- These REPLACE the previous programming puzzles
-- Difficulty 3–5 only. Nothing trivial.
-- ============================================================


-- ============================================================
-- C — DIFFICULTY 3
-- Struct padding, macro traps, pointer decay, sequence points
-- ============================================================

INSERT INTO puzzles (question, answer, hint, type, difficulty, time_limit) VALUES

('What is the output?
#include <stdio.h>
#define SQUARE(x) x*x
int main() {
    int a = 5;
    printf("%d", SQUARE(a+1));
    return 0;
}',
 '11',
 'Macro expands textually: a+1*a+1 = 5+5+1 = 11. Macros are not functions.',
 'C', 3, 25),

('What is sizeof this struct on a typical 64-bit system?
struct S {
    char a;
    int b;
    char c;
};',
 '12',
 'Compiler pads for alignment: char(1)+pad(3)+int(4)+char(1)+pad(3)=12. Not 6.',
 'C', 3, 25),

('What is the output?
int arr[3] = {1,2,3};
printf("%d", 2[arr]);',
 '3',
 'arr[2] == *(arr+2) == *(2+arr) == 2[arr]. Array indexing is commutative in C.',
 'C', 3, 25),

('What is the output?
int x = 10;
int y = (x > 5) ? (x << 1) : (x >> 1);
printf("%d", y);',
 '20',
 'x>5 is true. x<<1 = left shift 1 = multiply by 2. 10×2=20.',
 'C', 3, 25),

('What is the output?
#include <stdio.h>
int f(int x) { return x > 0 ? x + f(x-1) : 0; }
int main() {
    printf("%d", f(4));
    return 0;
}',
 '10',
 'Recursive sum: f(4)=4+f(3)=4+3+f(2)=4+3+2+f(1)=4+3+2+1+f(0)=10.',
 'C', 3, 25),

('What is the output?
int a = 5, b = 3;
int c = a++ * ++b;
printf("%d %d %d", a, b, c);',
 '6 4 20',
 'a++ uses 5 then a=6. ++b increments first so b=4. c=5*4=20.',
 'C', 3, 25),

('In C, what does this declare?
int (*fp)(int, int);',
 'POINTER TO FUNCTION RETURNING INT',
 'fp is a pointer to a function that takes two ints and returns int.',
 'C', 3, 25),

('What is the output?
char *s = "hello";
printf("%c", *(s+4));',
 'o',
 's points to h. s+4 points 4 bytes forward = last char o. Dereference it.',
 'C', 3, 25),

('What is the output?
int x = 5;
int y = x++ + x++;
printf("%d", y);',
 'UNDEFINED BEHAVIOR',
 'Modifying x twice without a sequence point between is undefined behavior in C.',
 'C', 3, 25),

('What is printed?
int a[] = {10,20,30,40,50};
int *p = a;
p += 2;
printf("%d %d", *p, *(p-1));',
 '30 20',
 'p starts at a[0]. p+=2 moves to a[2]=30. p-1 is a[1]=20.',
 'C', 3, 25),


-- ============================================================
-- C — DIFFICULTY 4
-- Function pointers, recursive macros, memory model,
-- alignment, pointer aliasing, setjmp, bitfields
-- ============================================================

('What is the output?
#include <stdio.h>
int add(int a,int b){ return a+b; }
int mul(int a,int b){ return a*b; }
int apply(int(*f)(int,int),int x,int y){ return f(x,y); }
int main(){
    printf("%d %d", apply(add,3,4), apply(mul,3,4));
    return 0;
}',
 '7 12',
 'Function pointers passed as arguments. apply calls whichever function is passed.',
 'C', 4, 20),

('What is the output?
#include <stdio.h>
#define MAX(a,b) ((a)>(b)?(a):(b))
int main(){
    int x=3, y=5;
    int z = MAX(x++, y++);
    printf("%d %d %d", x, y, z);
    return 0;
}',
 '4 7 6',
 'MAX expands: ((x++)>(y++)?(x++):(y++)). y>x so y++ runs TWICE. y goes 5->6->7. z=6.',
 'C', 4, 20),

('What is the size of this struct and why?
struct Bits {
    unsigned int a : 3;
    unsigned int b : 5;
    unsigned int c : 8;
    unsigned int d : 16;
};',
 '4',
 'Total bits: 3+5+8+16=32=4 bytes. Bitfields pack into the underlying type (unsigned int).',
 'C', 4, 20),

('What is the output?
#include <stdio.h>
void mystery(int *a, int *b){
    if(a != b){
        *a ^= *b;
        *b ^= *a;
        *a ^= *b;
    }
}
int main(){
    int arr[]={1,2,3};
    mystery(arr, arr);
    printf("%d", arr[0]);
    return 0;
}',
 '1',
 'When a==b (same pointer), XOR swap on same location gives 0. The if guard prevents that.',
 'C', 4, 20),

('What does this C declaration mean?
void (*signal(int, void(*)(int)))(int);',
 'SIGNAL TAKES INT AND FUNCTION POINTER RETURNS FUNCTION POINTER',
 'signal() takes an int and a void(*)(int), and returns a void(*)(int). Classic C declaration.',
 'C', 4, 20),

('What is the output?
#include <stdio.h>
int main(){
    int x = 0x41424344;
    char *p = (char*)&x;
    printf("%c", *p);
    return 0;
}',
 'D',
 'Little-endian system stores LSB first. 0x44=D is at lowest address. *p = D.',
 'C', 4, 20),

('What is the output?
#include <stdio.h>
int main(){
    int a[3][3] = {{1,2,3},{4,5,6},{7,8,9}};
    int *p = &a[0][0];
    printf("%d", *(p + 3*1 + 2));
    return 0;
}',
 '6',
 '2D array is flat in memory. Row 1, Col 2: index = 3*1+2 = 5. *(p+5) = a[1][2] = 6.',
 'C', 4, 20),

('What is the output?
#include <stdio.h>
static int count = 0;
int increment(){ return ++count; }
int main(){
    printf("%d %d %d",
        increment(), increment(), increment());
    return 0;
}',
 '3 2 1',
 'printf arguments evaluated right-to-left in most implementations. Static var increments each call.',
 'C', 4, 20),

('What is wrong with this code?
int* getArray(){
    int arr[5] = {1,2,3,4,5};
    return arr;
}',
 'RETURNS POINTER TO STACK MEMORY',
 'arr is a local variable. When function returns, stack frame is destroyed. Pointer becomes dangling.',
 'C', 4, 20),

('What is the output?
#include <stdio.h>
int main(){
    int x = 15;
    x &= ~(1 << 2);
    printf("%d", x);
    return 0;
}',
 '11',
 '1<<2=4=0100. ~4=...11111011. 15=1111. 1111 & 11111011 = 1011 = 11. Clears bit 2.',
 'C', 4, 20),

('What is the output?
#include <stdio.h>
int main(){
    int i;
    int a[5];
    for(i=0;i<5;i++) a[i]=i*i;
    int *p=a+2;
    printf("%d %d", p[-1], p[2]);
    return 0;
}',
 '1 16',
 'p=&a[2]. p[-1]=a[1]=1. p[2]=a[4]=16.',
 'C', 4, 20),

('What is the output?
#include <stdio.h>
#include <string.h>
int main(){
    char s[] = "hello";
    char *p = s;
    while(*p) p++;
    p--;
    while(p >= s){
        printf("%c", *p);
        p--;
    }
    return 0;
}',
 'olleh',
 'Advances p to null terminator, steps back one, then prints backwards until before start.',
 'C', 4, 20),

('What is the output?
#include <stdio.h>
int main(){
    unsigned char x = 200;
    x += 100;
    printf("%d", x);
    return 0;
}',
 '44',
 'unsigned char wraps at 256. 200+100=300. 300-256=44.',
 'C', 4, 20),

('What is the output?
#include <stdio.h>
int main(){
    int a = 0;
    int b = (a=5, a+3);
    printf("%d %d", a, b);
    return 0;
}',
 '5 8',
 'Comma operator: evaluates left, discards, evaluates right. a=5, then b=a+3=8.',
 'C', 4, 20),


-- ============================================================
-- C — DIFFICULTY 5 (BOSS LEVEL)
-- Aliasing rules, reentrant code, inline asm territory,
-- complex pointer casting, memory ordering
-- ============================================================

('BOSS — C STRICT ALIASING
What is the output and why is it dangerous?
#include <stdio.h>
int main(){
    float f = 3.14f;
    int *ip = (int*)&f;
    printf("%d", *ip);
    return 0;
}',
 'UNDEFINED BEHAVIOR VIOLATES STRICT ALIASING',
 'Accessing float memory through int* violates strict aliasing rule. Compiler may assume no aliasing and produce wrong results.',
 'C', 5, 60),

('BOSS — C FUNCTION POINTER TABLE
What is printed?
#include <stdio.h>
int f1(int x){ return x+1; }
int f2(int x){ return x*2; }
int f3(int x){ return x*x; }
int main(){
    int(*ops[])(int) = {f1,f2,f3};
    int x = 3;
    for(int i=0;i<3;i++) x = ops[i](x);
    printf("%d", x);
    return 0;
}',
 '64',
 'f1(3)=4. f2(4)=8. f3(8)=64. Function pointer array, called sequentially.',
 'C', 5, 60),

('BOSS — C VOLATILE MEMORY MAPPED IO
Why does removing volatile break this code?
volatile int *reg = (volatile int*)0xDEAD0000;
while(*reg == 0) {}',
 'COMPILER OPTIMIZES OUT THE LOOP READ',
 'Without volatile, compiler caches *reg in a register. Loop becomes infinite or eliminated. volatile forces re-read each iteration.',
 'C', 5, 90),

('BOSS — C RECURSIVE MACRO TRAP
What is the output?
#define A(x) B(x+1)
#define B(x) A(x+1)
int z = A(1);
printf("%d", z);',
 'COMPILATION ERROR INFINITE RECURSION',
 'Macros A and B call each other. C preprocessor does not recurse infinitely — it stops but produces malformed output. Won''t compile.',
 'C', 5, 90),

('BOSS — C POINTER ARITHMETIC TRAP
What is the output?
#include <stdio.h>
int main(){
    int a = 1, b = 2;
    int *p = &a;
    int *q = &b;
    printf("%d", (int)(q - p));
    return 0;
}',
 'UNDEFINED BEHAVIOR',
 'Pointer subtraction is only defined for pointers into the same array. a and b are separate objects. Result is implementation-defined at best.',
 'C', 5, 90),


-- ============================================================
-- PYTHON — DIFFICULTY 3
-- Late binding closures, MRO, __new__, descriptor protocol
-- ============================================================

('What is the output?
funcs = []
for i in range(3):
    funcs.append(lambda: i)
print([f() for f in funcs])',
 '[2, 2, 2]',
 'Late binding: lambdas capture variable i, not its value. By the time they run, i=2.',
 'PYTHON', 3, 25),

('What is the output?
funcs = []
for i in range(3):
    funcs.append(lambda x=i: x)
print([f() for f in funcs])',
 '[0, 1, 2]',
 'Default argument x=i captures the VALUE of i at lambda creation time. Fix for late binding.',
 'PYTHON', 3, 25),

('What is the output?
class A:
    def method(self): return "A"
class B(A):
    def method(self): return "B"
class C(A):
    def method(self): return "C"
class D(B, C):
    pass
print(D().method())',
 'B',
 'MRO: D→B→C→A (C3 linearization). D has no method, finds B first.',
 'PYTHON', 3, 25),

('What is the output?
x = 5
def f():
    print(x)
    x = 10
f()',
 'UnboundLocalError',
 'Assigning x inside f makes it local throughout f. Reading before assignment raises UnboundLocalError.',
 'PYTHON', 3, 25),

('What is the output?
a = [[0]*3 for _ in range(3)]
a[0][1] = 9
print(a[1][1])',
 '0',
 'List comprehension creates independent rows. Modifying a[0][1] does not affect a[1][1].',
 'PYTHON', 3, 25),

('What is the output?
a = [[0]*3]*3
a[0][1] = 9
print(a[1][1])',
 '9',
 'Multiplying a list replicates references. All 3 rows point to the SAME inner list.',
 'PYTHON', 3, 25),

('What is the output?
print(0.1 + 0.2 == 0.3)',
 'False',
 'IEEE 754 floating point: 0.1+0.2 = 0.30000000000000004. Not exactly 0.3.',
 'PYTHON', 3, 25),

('What is the output?
class Counter:
    count = 0
    def __init__(self):
        Counter.count += 1

a = Counter()
b = Counter()
c = Counter()
print(Counter.count)',
 '3',
 'count is a class variable. Each __init__ increments the class attribute. Three instances = 3.',
 'PYTHON', 3, 25),


-- ============================================================
-- PYTHON — DIFFICULTY 4
-- Descriptors, metaclasses, __slots__, coroutines, GC
-- ============================================================

('What is the output?
class Meta(type):
    def __new__(mcs, name, bases, dct):
        dct[''greet''] = lambda self: "meta"
        return super().__new__(mcs, name, bases, dct)

class MyClass(metaclass=Meta):
    pass

print(MyClass().greet())',
 'meta',
 'Metaclass __new__ injects greet into the class dict before the class is created.',
 'PYTHON', 4, 20),

('What is the output?
class Descriptor:
    def __get__(self, obj, objtype=None):
        return 42
    def __set__(self, obj, value):
        raise AttributeError("read only")

class MyClass:
    x = Descriptor()

m = MyClass()
print(m.x)',
 '42',
 'Descriptor protocol: __get__ is called on attribute access. Returns 42 regardless.',
 'PYTHON', 4, 20),

('What is the output?
import sys
def f():
    pass
print(sys.getrefcount(f) > 1)',
 'True',
 'getrefcount itself holds a reference. So refcount is always at least 2 when called.',
 'PYTHON', 4, 20),

('What is the output?
def gen():
    value = yield 1
    yield value * 2

g = gen()
print(next(g))
print(g.send(10))',
 '1\n20',
 'next(g) starts generator, yields 1. send(10) resumes, value=10, yields 10*2=20.',
 'PYTHON', 4, 20),

('What is the output?
class A:
    def __init__(self):
        self.x = 1
    def __getattr__(self, name):
        return 99

a = A()
print(a.x)
print(a.y)',
 '1\n99',
 '__getattr__ only called when normal lookup fails. a.x=1 found in __dict__. a.y not found, __getattr__ returns 99.',
 'PYTHON', 4, 20),

('What is the output?
class A:
    def __getattribute__(self, name):
        return 42

a = A()
print(a.anything)
print(a.x)',
 '42\n42',
 '__getattribute__ intercepts ALL attribute access, including existing ones. Always returns 42.',
 'PYTHON', 4, 20),

('What is the output?
from functools import reduce
data = [1,2,3,4,5]
result = reduce(lambda acc, x: acc * x, data, 1)
print(result)',
 '120',
 'reduce applies lambda cumulatively: 1*1=1, 1*2=2, 2*3=6, 6*4=24, 24*5=120.',
 'PYTHON', 4, 20),

('What is the output?
import itertools
gen = itertools.count(1)
result = sum(next(gen) for _ in range(5))
print(result)',
 '15',
 'count(1) yields 1,2,3,4,5,... Take 5: 1+2+3+4+5=15.',
 'PYTHON', 4, 20),

('What is the output?
class MyList(list):
    def append(self, val):
        super().append(val * 2)

ml = MyList()
ml.append(3)
ml.append(5)
print(ml)',
 '[6, 10]',
 'Overridden append doubles values before storing. super().append stores 6 and 10.',
 'PYTHON', 4, 20),

('What is the output?
def dec(f):
    def wrapper(*args, **kwargs):
        return f(*args, **kwargs) + 10
    return wrapper

@dec
@dec
def val():
    return 5

print(val())',
 '25',
 'Two decorators applied. Inner dec: val()=5+10=15. Outer dec: 15+10=25.',
 'PYTHON', 4, 20),

('What is the output?
sentinel = object()
d = {}
result = d.get(''key'', sentinel)
print(result is sentinel)',
 'True',
 'Key not in dict. get() returns default (sentinel). is checks identity — same object.',
 'PYTHON', 4, 20),

('What is the output?
class Singleton:
    _instance = None
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

a = Singleton()
b = Singleton()
print(a is b)',
 'True',
 '__new__ returns the same instance every time. a and b point to identical object.',
 'PYTHON', 4, 20),


-- ============================================================
-- PYTHON — DIFFICULTY 5 (BOSS LEVEL)
-- CPython internals, coroutine protocol, __class_getitem__,
-- memory model, frame objects
-- ============================================================

('BOSS — PYTHON COROUTINE CHAIN
What is the final output?
async def inner():
    return 42

async def outer():
    result = await inner()
    return result * 2

import asyncio
print(asyncio.run(outer()))',
 '84',
 'inner() returns 42. outer() awaits it, gets 42, returns 84. asyncio.run() executes the coroutine.',
 'PYTHON', 5, 60),

('BOSS — PYTHON DESCRIPTOR + META
What is the output?
class TypeChecked:
    def __set_name__(self, owner, name):
        self.name = name
    def __get__(self, obj, objtype=None):
        if obj is None: return self
        return obj.__dict__.get(self.name, 0)
    def __set__(self, obj, value):
        if not isinstance(value, int):
            raise TypeError
        obj.__dict__[self.name] = value

class Point:
    x = TypeChecked()
    y = TypeChecked()

p = Point()
p.x = 3
p.y = 4
print(p.x + p.y)',
 '7',
 'Descriptor stores value in instance __dict__ under its own name. Retrieves correctly. 3+4=7.',
 'PYTHON', 5, 60),

('BOSS — PYTHON MUTABLE CLOSURE
What is the output?
def make_counter():
    state = [0]
    def increment():
        state[0] += 1
        return state[0]
    return increment

c1 = make_counter()
c2 = make_counter()
print(c1(), c1(), c2(), c1())',
 '1 2 1 3',
 'Each make_counter() creates a fresh state=[0]. c1 and c2 have independent state. c1 called 3 times.',
 'PYTHON', 5, 90),

('BOSS — PYTHON __INIT_SUBCLASS__
What is the output?
class Plugin:
    registry = []
    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        Plugin.registry.append(cls.__name__)

class A(Plugin): pass
class B(Plugin): pass
class C(A): pass

print(Plugin.registry)',
 '[''A'', ''B'', ''C'']',
 '__init_subclass__ called whenever a class inherits from Plugin directly OR indirectly. C(A) also triggers it.',
 'PYTHON', 5, 90),


-- ============================================================
-- SYSTEMS & TECH — DIFFICULTY 3
-- Not conceptual definitions — actual reasoning puzzles
-- ============================================================

('You call malloc(0) in C. What does the standard say happens?',
 'RETURNS NULL OR UNIQUE POINTER',
 'C standard says malloc(0) may return NULL or a unique non-null pointer. Behavior is implementation-defined.',
 'TECH', 3, 25),

('In Python, why is dict faster than a list for lookups?',
 'HASH TABLE O(1) VS LINEAR SCAN O(N)',
 'dict uses a hash table — key lookup is O(1) average. List requires scanning each element — O(n) worst case.',
 'TECH', 3, 25),

('What is the output of: print(type(type))',
 '<class type>',
 'type is its own metaclass. type(type) returns type itself.',
 'TECH', 3, 25),

('How many times is "hello" printed?
int i = 0;
do {
    printf("hello\n");
    i++;
} while(i < 0);',
 '1',
 'do-while always executes body at least once. After first iteration i=1, condition false, exits.',
 'C', 3, 25),

('In TCP, what is the purpose of the TIME_WAIT state?',
 'ENSURE FINAL ACK RECEIVED AND OLD PACKETS EXPIRED',
 'Waits 2×MSL to ensure the final ACK was received and any delayed packets from the session have expired.',
 'TECH', 3, 25),


-- ============================================================
-- SYSTEMS & TECH — DIFFICULTY 4
-- Pipeline hazards, false sharing, MVCC, memory ordering
-- ============================================================

('What is false sharing in CPU caches and why does it hurt performance?',
 'DIFFERENT CORES INVALIDATE SAME CACHE LINE FOR DIFFERENT VARIABLES',
 'Two cores write to different variables that happen to share a cache line. Each write forces the other core to reload the entire line.',
 'TECH', 4, 20),

('What is the ABA problem in lock-free programming?',
 'VALUE CHANGES A TO B BACK TO A MAKING CAS INCORRECTLY SUCCEED',
 'Thread reads A. Another changes A→B→A. First thread CAS sees A and succeeds — but the state has changed in between.',
 'TECH', 4, 20),

('What does MVCC stand for and which problem does it solve?',
 'MULTIVERSION CONCURRENCY CONTROL ELIMINATES READ WRITE LOCKS',
 'Databases keep multiple versions of data. Readers see a consistent snapshot without blocking writers.',
 'TECH', 4, 20),

('In CPU memory ordering, what does a memory barrier (fence) do?',
 'PREVENTS INSTRUCTION REORDERING ACROSS THE BARRIER',
 'CPUs reorder instructions for performance. A barrier ensures all memory operations before it complete before those after it.',
 'TECH', 4, 20),

('What is the difference between a compile-time and runtime stack overflow?',
 'COMPILE TIME INFINITE TEMPLATE RECURSION RUNTIME INFINITE CALL STACK',
 'C++ templates can cause compile-time overflow. Recursive functions cause runtime stack overflow when call depth exceeds limit.',
 'TECH', 4, 20),

('What does the mmap system call do?',
 'MAPS FILE OR DEVICE INTO PROCESS VIRTUAL MEMORY',
 'mmap creates a mapping in virtual address space — can be file-backed or anonymous. Used for IPC, efficient file I/O, shared memory.',
 'TECH', 4, 20),

('In Python, what is the difference between __str__ and __repr__?',
 'REPR UNAMBIGUOUS FOR DEVELOPERS STR READABLE FOR USERS',
 '__repr__ should return a string that could recreate the object. __str__ is for human-readable display. print() calls __str__.',
 'TECH', 4, 20),

('What is consistent hashing and why is it used in distributed systems?',
 'MINIMIZES REMAPPING WHEN NODES ADDED OR REMOVED',
 'Maps both data and nodes onto a ring. Adding/removing a node only remaps 1/n of keys instead of all keys.',
 'TECH', 4, 20),

('What is a B+ tree and how does it differ from a B-tree for database indexing?',
 'B PLUS STORES DATA ONLY IN LEAVES ENABLING RANGE SCANS',
 'B+ tree: internal nodes store only keys for routing, all data in leaf nodes linked together. B-tree stores data at every node.',
 'TECH', 4, 20),

('In Python, what happens when you do: a, *b, c = [1,2,3,4,5]?',
 'A=1 B=[2,3,4] C=5',
 'Extended unpacking. First goes to a, last to c, everything in between to b as a list.',
 'PYTHON', 4, 20),


-- ============================================================
-- SYSTEMS — DIFFICULTY 5 (BOSS LEVEL)
-- The kind of questions that end interviews
-- ============================================================

('BOSS — SYSTEMS
You have 2 threads. Thread 1 sets flag=1 then reads data. Thread 2 sets data then reads flag.
No synchronization. On a modern CPU, can Thread 1 see flag=1 but stale data?',
 'YES DUE TO MEMORY REORDERING',
 'Without barriers, CPU and compiler may reorder stores and loads. Thread 1 may see flag=1 before data is visible. Acquire-release semantics required.',
 'TECH', 5, 90),

('BOSS — PYTHON INTERNALS
What is the output?
import dis
def f(x):
    return x * 2

code = f.__code__
print(code.co_varnames, code.co_argcount)',
 '(''x'',) 1',
 '__code__ exposes bytecode metadata. co_varnames lists local variable names. co_argcount is number of arguments.',
 'PYTHON', 5, 90),

('BOSS — C + SYSTEMS FUSION
In C on a little-endian machine:
int x = 0x01020304;
char *p = (char*)&x;
What does p[0] contain in hex?',
 '0x04',
 'Little-endian stores LSB at lowest address. 0x01020304: byte at lowest address = 0x04.',
 'C', 5, 90),

('BOSS — ALGORITHM COMPLEXITY
A hash table has load factor α. Average successful lookup cost in chaining is:
1 + α/2. If α = 0.75, what is the average comparisons?',
 '1.375',
 '1 + 0.75/2 = 1 + 0.375 = 1.375 comparisons on average.',
 'TECH', 5, 60),

('BOSS — PYTHON GC
Python uses reference counting + cyclic GC. What scenario does reference counting ALONE fail to collect?
Give the simplest example structure.',
 'CIRCULAR REFERENCE',
 'a = []. a.append(a). a references itself. refcount never reaches 0. Only cyclic GC handles this.',
 'PYTHON', 5, 90);
