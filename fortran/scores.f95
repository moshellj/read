program scores
        implicit none
    character(:), allocatable::line, outline, word, filename
    character, dimension(:), allocatable :: string
    integer :: filesize
    
    interface
        subroutine get_next_token(inline, outline, word)
            character (*) :: inline
            character(:), allocatable ::outline, word
        end subroutine get_next_token
        subroutine read_file(filename, string, filesize)
            character(:), allocatable :: filename
            character, dimension(:), allocatable :: string
            integer(KIND=4) :: filesize
        end subroutine
    end interface
    
    filename = "/home/moshell_jw/alice.txt"!replace with argument
    
    call read_file(filename, string, filesize)
    !write (*,*) string
    
    goto 300    
    line = "A line of text"
    print *, line
    print *, "The length of the string is ", len(line)
    
    outline=line
    
    do while (len(outline) .ne. 0)
        call get_next_token(line, outline, word)
        print *, word
        line = outline
    enddo
    300 continue
end program scores

!shamelessly lifted from the example
subroutine get_next_token(inline, outline, token)
    character (*)::inline
    character(:), allocatable::outline, token
    integer::i,j
    logical::foundFirst, foundLast

    foundFirst=.false.
    foundLast=.false.
    i=0

    ! find non-blank
    do while (.not. foundFirst .and. (i < len(inline)))
        if (inline(i:i) .eq. " ") then
            i = i + 1
        else
            foundFirst = .true.
        endif
    enddo
    
    j = i
    do while (foundFirst .and. .not. foundLast .and. (j < len(inline)))
        if(inline(j:j) .ne. " ") then
            j = j + 1
        else
            foundLast = .true.
        endif
    enddo
    
    token = trim(inline(i:j))
    outline = trim(inline(j+1:len(inline)))
end subroutine get_next_token

!shamelessly lifted from the example reader3
subroutine read_file(filename, string, filesize)
    character(:), allocatable :: filename
    character, dimension(:), allocatable :: string
    integer :: counter, filesize
    character (LEN=1) :: input
    
    inquire(FILE=filename, SIZE=filesize)
    open(unit=5,status="old",access="direct",form="unformatted",recl=1,FILE=filename)
    allocate(string(filesize))
    filesize = size(string) ! WHY DOES ALLOCATE SET THE SIZE VARIABLE TO ZERO
    counter=1
    100 read(5, rec=counter, err=200) input
        string (counter:counter) = input
        counter = counter + 1
        goto 100
    200 continue
    counter = counter-1
    close(5)
end subroutine read_file
