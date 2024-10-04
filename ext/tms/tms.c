#include "ruby.h"
#include "ruby/encoding.h"
#include <CoreServices/CoreServices.h>
#include <SystemConfiguration/SystemConfiguration.h>

#ifdef HAVE_RUBY_ENCODING_H
#define UTF8_STR_NEW2(str) rb_enc_associate_index(rb_str_new2(str), rb_enc_find_index("UTF-8"))
#else
#define UTF8_STR_NEW2(str) rb_str_new2(str)
#endif

static VALUE backup_volume(VALUE self){
	OSStatus status = pathTooLongErr;
	char *path;
	size_t pathLength;

	CFDataRef aliasData;
	AliasHandle alias;
	FSRef fs;
	Boolean wasChanged;

	aliasData = CFPreferencesCopyAppValue(CFSTR("BackupAlias"), CFSTR("com.apple.TimeMachine"));
	if (aliasData) {
		if (noErr == PtrToHand(CFDataGetBytePtr(aliasData), (Handle *)&alias, CFDataGetLength(aliasData))) {
			if (noErr == FSResolveAlias(NULL, alias, &fs, &wasChanged)) {
				path = malloc(pathLength = 256);
				while (noErr != (status = FSRefMakePath(&fs, (UInt8*)path, pathLength))) {
					if (pathTooLongErr == status) {
						pathLength += 256;
						path = reallocf(path, pathLength);
					}
				}
			}
			DisposeHandle((Handle)alias);
		}
		CFRelease(aliasData);
	}

	if (noErr == status) {
		return UTF8_STR_NEW2(path);
	} else {
		return Qnil;
	}
}

static VALUE computer_name(VALUE self){
	char *name;
	size_t nameLength;

	CFStringRef cfName;

	if (cfName = SCDynamicStoreCopyComputerName(NULL, NULL)) {
		name = malloc(nameLength = 256);
		while (!CFStringGetCString(cfName, name, nameLength, kCFStringEncodingUTF8)) {
			nameLength += 256;
			name = reallocf(name, nameLength);
		}

		CFRelease(cfName);

		return UTF8_STR_NEW2(name);
	} else {
		return Qnil;
	}
}

void Init_helpers() {
	VALUE cTms = rb_define_module("Tms");
	rb_define_singleton_method(cTms, "backup_volume", backup_volume, 0);
	rb_define_singleton_method(cTms, "computer_name", computer_name, 0);
}
