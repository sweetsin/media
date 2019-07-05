/*
 * SRT - Secure, Reliable, Transport
 * Copyright (c) 2018 Haivision Systems Inc.
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * 
 */

#ifndef INC__VERBOSE_HPP
#define INC__VERBOSE_HPP

#include <iostream>
#if SRT_ENABLE_VERBOSE_LOCK
#include <mutex>
#endif

namespace Verbose
{

extern bool on;
extern std::ostream* cverb;

struct LogNoEol { LogNoEol() {} };
#if SRT_ENABLE_VERBOSE_LOCK
struct LogLock { LogLock() {} };
#endif

class Log
{
    bool noeol;
#if SRT_ENABLE_VERBOSE_LOCK
    bool lockline;
#endif
public:

    Log():
        noeol(false)
#if SRT_ENABLE_VERBOSE_LOCK
        ,lockline(false)
#endif
    {}

    template <class V>
    Log& operator<<(const V& arg)
    {
        // Template - must be here; extern template requires
        // predefined specializations.
        if (on)
            (*cverb) << arg;
        return *this;
    }

    Log& operator<<(LogNoEol);
#if SRT_ENABLE_VERBOSE_LOCK
    Log& operator<<(LogLock);
#endif
    ~Log();
};

}

inline Verbose::Log Verb() { return Verbose::Log(); }

// Manipulator tags
static const Verbose::LogNoEol VerbNoEOL;
#if SRT_ENABLE_VERBOSE_LOCK
static const Verbose::LogLock VerbLock;
#endif

#endif
