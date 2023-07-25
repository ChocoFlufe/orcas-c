ENTRY(_start)

SECTIONS
{
    . = 0xa000;

    .text : ALIGN(4K)
    {
        _text_start = .;
        *(.entry)
        *(.text)
        _text_end = .;
    }

    .rodata : ALIGN(4K)
    {
        _rodata_start = .;
        *(.rodata)
        _rodata_end = .;
    }

    .data : ALIGN(4K)
    {
        _data_start = .;
        *(.data)
        _data_end = .;
    }

    .bss : ALIGN(4K)
    {
        _bss_start = .;
        *(COMMON)
        *(.bss)
        _bss_end = .;
    }

    _end = .;

    /DISCARD/ :
    {
        *(.comment)
        *(.eh_frame)
        *(.note)
        *(.pdf)
        *(.note.gnu.build-id)
    }
}

