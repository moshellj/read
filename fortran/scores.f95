program scores
    implicit none
    character(:), allocatable::line, outline, token, filename, string
    integer :: filesize
    
    interface
        subroutine get_next_token(inline, outline, token)
            character(:), allocatable:: inline
            character(:), allocatable :: outline, token
        end subroutine get_next_token
        subroutine read_file(filename, string, filesize)
            character(:), allocatable :: filename, string
            integer(KIND=4) :: filesize
        end subroutine
        subroutine fix_token(string)
            character(:), allocatable :: string
        end subroutine fix_token
    end interface
    
    filename = "/home/moshell_jw/alice.txt"!replace with argument
    
    call read_file(filename, string, filesize)
    !write (*,*) string
    !line = "A line of text"
    
    outline = " "
    
    do while (len(outline) .ne. 0)
        call get_next_token(string, outline, token)
        call fix_token(token)
        print *, token, len(token)
        string = outline
    enddo
    
end program scores

!shamelessly lifted from the example
!divides by whitespace and returns the next token without modifying it.
subroutine get_next_token(inline, outline, token)
    character(:), allocatable::inline
    character(:), allocatable::outline, token
    integer::i,j
    logical::foundFirst, foundLast

    foundFirst=.false.
    foundLast=.false.
    i=1

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
        if(inline(j:j) .ne. " " .and. inline(j:j) .ne. "\n") then
            j = j + 1
        else
            foundLast = .true.
        endif
    enddo
    token = trim(inline(i:j-1))
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

! modifies a token string for ease of parsing.
! strips nonletters except for ' (and thus may return an empty string)
! be sure to reason about sentence-ending before calling this
! normalizes to lowercase. Elemental, for chall list.
subroutine fix_token(string)
    character(:), allocatable :: string
    character(:), allocatable :: stripset
    integer :: writehead, readhead
    stripset = "!@#$%&^*()_+-=[]\{}|;" // '"' // ":,./<>?`~"
    !strip: rewrite string to itself. if invalid character, do not write, do not
    !       move write head. trim end.
    writehead = 1
    readhead = 1
    do while (readhead <= len(string))
        if ( scan(string(readhead:readhead), stripset) > 0 ) then
            ! do nothing
        else
            !lowercasize: if 65 <= c <= 90, add 32
            if ( 65 <= iachar(string(readhead:readhead)) .and. iachar( &
                string(readhead:readhead)) <= 90) then
                string(readhead:readhead) = achar(iachar(string(readhead:readhead)) + 32)
            end if
            string(writehead:writehead) = string(readhead:readhead)
            writehead = writehead + 1
        end if
        readhead = readhead + 1
    enddo
    string = string(1:writehead - 1)
end subroutine fix_token
