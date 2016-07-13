Ddoc

$(DERS_BOLUMU $(IX lifetime) 生命周期和基本操作)

$(P
我们很快将会讲到结构体（ struct ）， 它最基本的特性是允许你自己定义特定的类型。结构体是为了根据特殊的需求去定制自己的类型，利用基本类型和其他自定义类型组合去实现。讲完结构体，我们将会讲到D语言实现面向对象编程的基础 ———— 类 （ class ）。
)

$(P
在讲结构体和类之前，我们要先说一些其他重要的概念，以便以后更好的理解结构体和类的不同。
)

$(P
我们在前面已经讲过 $(I 变量 ），有一部分的具体对象被我们称结构体（ struct ）和类( class ) 。我们会继续在这一章中调用两个概念变量。
We have been calling any piece of data that represented a concept in a program a $(I variable). In a few places we have called struct and class variables specifically as $(I objects). I will continue calling both of these concepts variables in this chapter.
)

$(P
虽然这长只用到基本类型、切片（ slices ） 和关联数组， 但是本章讲的概念同样适用于自定义类型。
)

$(H5 $(IX variable, lifetime) 变量的生命周期)

$(P
变量的生命周期是指 这个变量从定义到释放， 对于很多类型，$(I 变得无法到达/使用 ) 和 $(I 被释放 ) 不是在相同的时间的。
The time between when a variable is defined and when it is $(I finalized) is the lifetime of that variable. Although it is the case for many types, $(I becoming unavailable) and $(I being finalized) need not be at the same time.
)

$(P
你应该记得在$(LINK2 /ders/d.cn/name_space.html, 名称的作用域章节) 里讲到的变量是怎么变得无法到达/使用 的。在例子部分，退出名字定义的所在的那个作用域就会使变量变得无法到达。
You would remember from the $(LINK2 /ders/d.en/name_space.html, Name Scope chapter) how variables become unavailable. In simple cases, exiting the scope where a variable has been defined would make that variable unavailable.
)

$(P
让我们看下下面的例子去回忆下：
Let's consider the following example as a reminder:
)

---
void speedTest() {
    int speed;               // 一个变量  

    foreach (i; 0 .. 10) {
        speed = 100 + i;     // ... 改变10次值
        // ...
    }
} // ← 'speed' 现在是不可到达的在这个位置
---

$(P
上面代码中，变量 $(C speed) 的生命周期是在$(C speedTest()) function退出时结束。上面代码中也只有一个变量，它的值改变了多次，从100到109.
The lifetime of the $(C speed) variable in that code ends upon exiting the $(C speedTest()) function. There is a single variable in the code above, which takes ten different values from 100 to 109.
)

$(P
讲起来变量的生命周期，下面代码里的就和上面代码中的完全不一样了 ：
When it comes to variable lifetimes, the following code is very different compared to the previous one:
)

---
void speedTest() {
    foreach (i; 0 .. 10) {
        int speed = 100 + i; // 十个对立的变量
        // ...
    } // ← 每个变量的生命周期都是到这里结束。Lifetime of each variable ends here.
}
---

$(P
这段代码里有十个独立的变量，每一个都有一个值。在每一次循环开始，一个新的变量的生存周期开始，当循环结束的时候生命周期也就结束了。
There are ten separate variables in that code, each taking a single value. Upon every iteration of the loop, a new variable starts its life, which eventually ends at the end of each iteration.
)

$(H5 $(IX parameter, lifetime) 函数参数的生存周期 )

$(P
参数生存周期取决于它的描述符。
The lifetime of a parameter depends on its qualifiers:
)

$(P
$(IX ref, parameter lifetime) $(C ref): 函数的参数仅仅是在函数调用的时候指定的实际值的一个别名。 $(C ref) 函数的参数不影响实际变量的生命周期。
)

$(P
$(IX in, parameter lifetime) $(C in): 对于 $(I 值类型 ), 参数的生存周期从进入很熟开始，推出函数时结束。 对于 $(I 引用类型), 参数的生存周期和 $(C ref) 修饰是一样的.
)

$(P
$(IX out, parameter lifetime) $(C out): 和 $(C ref) 一样, 数的参数仅仅是在函数调用的时候指定的实际值的一个别名。 它们唯一的区别就是 这个变量在函数开始的时候会被自动重新初始化为 $(C .init) .
)

$(P
$(IX lazy, parameter lifetime) $(C lazy): 参数的生存周期实际上只有在实际使用的才会存在。
)

$(P
下面例子中我们使用这四种修饰的参数，并在注释中解释：
The following example uses these four types of parameters and explains their lifetimes in program comments:
)

---
void main() {
    int main_in;      /* main_in值会复制到参数里 */

    int main_ref;     /* main_ref 传递到函数里的还是它自己 */

    int main_out;     /* main_out 传递到函数里的还是它自己.  
                       * 它的值在函数开始执行的时候会被设置为 int.init */

    foo(main_in, main_ref, main_out, aCalculation());
}

void foo(
    in int p_in,       /* p_in 的生存周期是在开始函数执行的时候开始，
                        * 在函数执行完的时候结束。*/

    ref int p_ref,     /* p_ref 只是 main_ref 的一个别名 */

    out int p_out,     /* p_out 是 main_out 的一个别名。 
                        * 它的值在函数开始执行的时候会被设置为 int.init */

    lazy int p_lazy) { /* p_lazy 的生命周期是在其使用的时候开始，使用完就结束。
                        * p_lazy 在函数使用中的值是每次通过调用 aCalculation() 计算出来的。 */
    // ...
}

int aCalculation() {
    int result;
    // ...
    return result;
}
---

$(H5 基本操作 Fundamental operations)

$(P
不管什么类型，它们都有生存周期的三种基本操作。
Regardless of its type, there are three fundamental operations throughout the lifetime of a variable:
)

$(UL
$(LI $(B 初始化): 开始其生命周期 )
$(LI $(B 终止): 生命周期结束 )
$(LI $(B 赋值 ): 整个的改变其值 )
)

$(P
你首先必须初始化，才能作为一个对象。对于有些类型这可能是最后的操作。变量的值可能会更改在其生命周期之内。
To be considered an object, it must first be initialized. There may be final operations for some types. The value of a variable may change during its lifetime.
)

$(H6 $(IX initialization) 初始化)

$(P
每一个变量在使用之前都必须初始化。初始化分为两步进行：
)

$(OL

$(LI $(B 为变量分配空间 ): 这个空间是这个变量的值在内存中的储存位置。)

$(LI $(B 构造 ): 设置这个变量的第一值到它的内存空间 ( 或者 是结构体或者类的成员的值 )。)

)

$(P
没一个变量在内存中都有专门为其保留的内存空间。编译产生一些代码就是为变量预先申请内存空间
Every variable lives in a place in memory that is reserved for it. Some of the code that the compiler generates is about reserving space for each variable.
)

$(P
让我们看下以下变量：
Let's consider the following variable:
)

---
    int speed = 123;
---

$(P
根据我们讲过的$(LINK2 /ders/d.cn/value_vs_reference.html, 值类型和引用类型)那节,我们可以想象一下这个变量在内存中的状态。
As we have seen in $(LINK2 /ders/d.en/value_vs_reference.html, the Value Types and Reference Types chapter), we can imagine this variable living on some part of the memory:
)

$(MONO
   ──┬─────┬─────┬─────┬──
     │     │ 123 │     │
   ──┴─────┴─────┴─────┴──
)

$(P
一个变量被放置在内存的位置称为它的地址。在某种意义上，变量住在那个地址上。即使变量的值发生了变化，这个新值也还是存储在原来的那个地址的。
The memory location that a variable is placed at is called its address. In a sense, the variable lives at that address. When the value of a variable is changed, the new value is stored at the same place:
)

---
    ++speed;
---

$(P
The new value would be at the same place where the old value has been:
)

$(MONO
   ──┬─────┬─────┬─────┬──
     │     │ 124 │     │
   ──┴─────┴─────┴─────┴──
)

$(P
Construction is necessary to prepare variables for use. Since a variable cannot be used reliably before being constructed, it is performed by the compiler automatically.
)

$(P
Variables can be constructed in three ways:
)

$(UL
$(LI $(B By their default value): when the programmer does not specify a value explicitly)
$(LI $(B By copying): when the variable is constructed as a copy of another variable of the same type)
$(LI $(B By a specific value): when the programmer specifies a value explicitly)
)

$(P
When a value is not specified, the value of the variable would be the $(I default) value of its type, i.e. its $(C .init) value.
)

---
    int speed;
---

$(P
The value of $(C speed) above is $(C int.init), which happens to be zero. Naturally, a variable that is constructed by its default value may have other values during its lifetime (unless it is $(C immutable)).
)

---
    File file;
---

$(P
With the definition above, the variable $(C file) is a $(C File) object that is not yet associated with an actual file on the file system. It is not usable until it is modified to be associated with a file.
)

$(P
Variables are sometimes constructed as a copy of another variable:
)

---
    int speed = otherSpeed;
---

$(P
$(C speed) above is constructed by the value of $(C otherSpeed).
)

$(P
As we will see in later chapters, this operation has a different meaning for class variables:
)

---
    auto classVariable = otherClassVariable;
---

$(P
Although $(C classVariable) starts its life as a copy of $(C otherClassVariable), there is a fundamental difference with classes: Although $(C speed) and $(C otherSpeed) are distinct values, $(C classVariable) and $(C otherClassVariable) both provide access to the same value. This is the fundamental difference between value types and reference types.
)

$(P
Finally, variables can be constructed by the value of an expression of a compatible type:
)

---
   int speed = someCalculation();
---

$(P
$(C speed) above would be constructed by the return value of $(C someCalculation()).
)

$(H6 $(IX finalization) $(IX destruction) Finalization)

$(P
Finalizing is the final operations that are executed for a variable and reclaiming its memory:
)

$(OL
$(LI $(B Destruction): The final operations that must be executed for the variable.)
$(LI $(B Reclaiming the variable's memory): Reclaiming the piece of memory that the variable has been living on.)
)

$(P
For simple fundamental types, there are no final operations to execute. For example, the value of a variable of type $(C int) is not set back to zero. For such variables there is only reclaiming their memory, so that it will be used for other variables later.
)

$(P
On the other hand, some types of variables require special operations during finalization. For example, a $(C File) object would need to write the characters that are still in its output buffer to disk and notify the file system that it no longer uses the file. These operations are the destruction of a $(C File) object.
)

$(P
Final operations of arrays are at a little higher-level: Before finalizing the array, first its elements are destructed. If the elements are of a simple fundamental type like $(C int), then there are no special final operations for them. If the elements are of a struct or a class type that needs finalization, then those operations are executed for each element.
)

$(P
Associative arrays are similar to arrays. Additionally, the keys may also be finalized if they are of a type that needs destruction.
)

$(P $(B The garbage collector:) D is a $(I garbage-collected) language. In such languages finalizing an object need not be initiated explicitly by the programmer. When a variable's lifetime ends, its finalization is automatically handled by the garbage collector. We will cover the garbage collector and special memory management in $(LINK2 /ders/d.en/memory.html, a later chapter).
)

$(P
Variables can be finalized in two ways:
)

$(UL
$(LI $(B When the lifetime ends): The finalization happens upon the end of life of the variable.)
$(LI $(B Some time in the future): The finalization happens at an indeterminate time in the future by the garbage collector.)
)

$(P
Which of the two ways a variable will be finalized depends primarily on its type. Some types like arrays, associative arrays and classes are normally destructed by the garbage collector some time in the future.
)

$(H6 $(IX assignment) Assignment)

$(P
The other fundamental operation that a variable experiences during its lifetime is assignment.
)

$(P
For simple fundamental types assignment is merely changing the value of the variable. As we have seen above on the memory representation, an $(C int) variable would start having the value 124 instead of 123. However, more generally, assignment consists of two steps, which are not necessarily executed in the following order:
)

$(UL
$(LI $(B Destructing the old value))
$(LI $(B Constructing the new value))
)

$(P
These two steps are not important for simple fundamental types that don't need destruction. For types that need destruction, it is important to remember that assignment is a combination of the two steps above.
)

Macros:
        SUBTITLE=Lifetimes and Fundamental Operations

        DESCRIPTION=Introducing the concepts of initialization, finalization, construction, destruction, and assignment and defining the lifetimes of variables.

        KEYWORDS=d programming lesson book tutorial constructor destructor
