#include "leaks.hpp"

std::vector<ptr> mallocList;

bool operator==(ptr const & p1, ptr const & p2)
{
    return (p1.p == p2.p);
}

#ifdef __APPLE__
void * malloc(size_t size)
{
    void *(*libc_malloc)(size_t) = (void *(*)(size_t))dlsym(RTLD_NEXT, "malloc");
    void * p = libc_malloc(size);
    mallocListAdd(p, size);
    return (p);
}
#endif

#ifdef __unix__
extern "C" void *__libc_malloc(size_t);
extern "C" void __libc_free(void *);
static int in_hook = 0;

void * malloc(size_t size) throw()
{
    void * p = __libc_malloc(size);
    if (!in_hook)
    {
        in_hook = 1;
        mallocListAdd(p, size);
        in_hook = 0;
    }
    return (p);
}
#endif

#ifdef __APPLE__
void free(void * p)
{
    void (*libc_free)(void*) = (void (*)(void *))dlsym(RTLD_NEXT, "free");
    libc_free(p);
    mallocListRemove(p);
}
#endif

#ifdef __unix__
void free(void * p) throw()
{
    __libc_free(p);
    if (!in_hook)
    {
        in_hook = 1;
        mallocListRemove(p);
        in_hook = 0;
    }
}
#endif

void mallocListAdd(void * p, size_t size)
{
    mallocList.push_back(ptr(p, size));
}

void mallocListRemove(void * p)
{
    std::vector<ptr>::iterator it = find(mallocList.begin(), mallocList.end(), ptr(p));
    if (it != mallocList.end())
        mallocList.erase(it);
}

void showLeaks(void)
{
    if (mallocList.size() != 0)
    {
        std::ostringstream ss; ss << FG_RED << "LEAKS.KO "; write(1, ss.str().c_str(), ss.str().size());
        std::vector<ptr>::iterator it = mallocList.begin(); std::vector<ptr>::iterator ite = mallocList.end();
        for (; it != ite; ++it)
            {std::ostringstream ss; ss << "[" << it->p << " : " << it->size << "] "; write(1, ss.str().c_str(), ss.str().size());}
        if (showTest) std::cout << ENDL;
    }
    mallocList.clear();
}
