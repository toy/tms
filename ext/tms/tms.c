#include "ruby.h"
#include <CoreServices/CoreServices.h>

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
		return rb_str_new2(path);
	} else {
		return Qnil;
	}
}

void Init_tms() {
	VALUE cTms = rb_define_module("Tms");
	rb_define_singleton_method(cTms, "backup_volume", backup_volume, 0);
}
