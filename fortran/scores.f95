program scores
    implicit none
    character(:), allocatable::line, outline, token, filename, string
    integer :: filesize
    
    interface
        subroutine get_next_token(inline, outline, token)
            character (*) :: inline
            character(:), allocatable :: outline, token
        end subroutine get_next_token
        subroutine read_file(filename, string, filesize)
            character(:), allocatable :: filename, string
            integer(KIND=4) :: filesize
        end subroutine
    end interface
    
    filename = "/home/moshell_jw/alice.txt"!replace with argument
    
    call read_file(filename, string, filesize)
    write (*,*) string
    !line = "A line of text"
    goto 300
    outline = " "
    
    do while (len(outline) .ne. 0)
        call get_next_token(line, outline, token)
        print *, token
        line = outline
    enddo
    300 continue
end program scores

!shamelessly lifted from the example
!divides by whitespace and returns the next thing.
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
    ! while not-whitespace not found and i < length of line
        if (inline(i:i) .eq. " " .or. inline(i:i) .eq. "\n") then 
            !if line at pos i == space or enter
            i = i + 1!keep searching
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
    character(:), allocatable :: filename, string
    integer :: counter, filesize
    character (LEN=1) :: input
    
    inquire(FILE=filename, SIZE=filesize)
    open(unit=5,status="old",access="direct",form="unformatted",recl=1,FILE=filename)
    allocate( character (LEN=filesize) :: string)
    !filesize = size(string)
    counter=1
    100 read(5, rec=counter, err=200) input
            !write (*,*) counter
        string (counter:counter) = input
        counter = counter + 1
        goto 100
    200 continue
    counter = counter-1
    close(5)
end subroutine read_file
