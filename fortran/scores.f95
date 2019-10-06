!fortran sucks
program scores
    implicit none
    character(:), allocatable::line, outline, token, filename, string
    character(:), allocatable:: dachwolifina ! dale chall word list file name
    integer :: filesize
    character(len=200) :: tempfilename
    integer :: syllcount, wordcount, sentcount, diffcount, syllinword, i
    character(:), allocatable :: sentend, letters, vowels
    logical :: validsent, lastcharvowel
    real(kind=8) :: alpha, beta, dcalpha, dcscore
    character(20), dimension(:), allocatable :: dcwordlist
   
    !interface
    !    subroutine get_next_token(inline, outline, token)
    !        character(:), allocatable:: inline
    !        character(:), allocatable :: outline, token
    !    end subroutine get_next_token
    !    subroutine read_file(filename, string, filesize)
    !        character(:), allocatable :: filename, string
    !        integer(KIND=4) :: filesize
    !    end subroutine
    !    subroutine fix_token(string)
    !        character(:), allocatable :: string
    !    end subroutine fix_token
    !    subroutine get_easies(filename, dict)
    !        character(:), allocatable :: filename
    !        character(20), dimension(:), allocatable :: dict
    !    end subroutine get_easies
    !end interface
    
    sentend = "!?.;:"
    outline = " "
    dachwolifina = "/pub/pounds/CSC330/dalechall/wordlist1995.txt"
    letters = "qwertyuiopasdfghjklzxcvbnm"
    vowels = "aeiouy"
    
    call get_command_argument(1, tempfilename)
    filename = tempfilename ! necessary
    !filename = "/home/moshell_jw/alice.txt"!replace with argument
    call read_file(filename, string, filesize)
    call get_easies(dachwolifina, dcwordlist)
    !write (*,*) string
    
    ! count syllables, words, and sentences
    do while (len(outline) .ne. 0)
        call get_next_token(string, outline, token)
        
        !punct
        if (scan(token, sentend) > 0 .and. validsent) then
            sentcount = sentcount + 1
            validsent = .false.
        endif
        
        call fix_token(token)
        
        !word
        if(scan(token, letters) > 0) then
            wordcount = wordcount + 1
            validsent = .true.
            
            !dcwl
            if(.not. is_easy(token, dcwordlist)) then
                diffcount = diffcount + 1
            endif
            
            !syllables
            i = 1
            lastcharvowel = .false.
            do while (i <= len(token))
                if(scan(token(i:i), vowels) > 0) then!vowel
                    if(.not. lastcharvowel) then
                        syllinword = syllinword + 1
                    endif
                    lastcharvowel = .true.
                else
                    lastcharvowel = .false.
                endif
                i = i + 1
            enddo
            if(token(len(token):len(token)) .eq. "e") then
                syllinword = syllinword - 1
            endif
            if(syllinword < 1) then
                syllinword = 1
            endif
            syllcount = syllcount + syllinword
        endif
        
        syllinword = 0
        string = outline
    enddo
    
    !calculate scores
    alpha = real(syllcount, 8) / real(wordcount, 8)
    beta = real(wordcount, 8) / real(sentcount, 8)
    dcalpha = real(diffcount, 8) / real(wordcount, 8)
    print *, "diffcount= ", diffcount, wordcount, dcalpha
    dcscore = dcalpha*15.79 + beta*0.0496
    if(dcalpha > 0.05) then
        dcscore = dcscore + 3.6365
    endif
    print "(A,I3)", "Flesch index: ", nint(206.835 - alpha*84.6 - beta*1.015)
    print "(A,F4.1)", "Flesch-Kincaid index: ", (alpha*11.8 + beta*0.39 - 15.59)
    print "(A,F8.1)", "Dale-Chall Readability Score: ", dcscore
    

contains
!end program scores

! returns a array of processed strings representing the dale-chall dictionary.
subroutine get_easies(filename, dict)
    character(:), allocatable :: filename, filestring, outline, token
    character(20), dimension(:), allocatable :: dict
    integer :: filesize, i
    
    !interface
    !    subroutine get_next_token(inline, outline, token)
    !        character(:), allocatable:: inline
    !        character(:), allocatable :: outline, token
    !    end subroutine
    !    subroutine read_file(filename, string, filesize)
    !        character(:), allocatable :: filename, string
    !        integer(KIND=4) :: filesize
    !    end subroutine
    !    subroutine fix_token(string)
    !        character(:), allocatable :: string
    !    end subroutine
    !end interface
    
    i = 1
    call read_file(filename, filestring, filesize)
    
    outline = " "
    
    allocate(dict(2950)) !best practice
    do while (len(outline) .ne. 0)
        call get_next_token(filestring, outline, token)
        call fix_token(token)
        dict(i) = token
        !print *, i,'.', dict(i),'.',token,'.'
        i = i + 1
        filestring = outline
    enddo
end subroutine get_easies

!does binary search for text in wordlist
logical function is_easy (text, dcwordlist) result(give)
    character(:), allocatable, intent(in) :: text
    character(20), allocatable, dimension(:), intent(in) :: dcwordlist
    integer :: lob, hib, mid
    lob = 1
    hib = 2950
    do while(lob < hib)
        mid = (hib + lob) / 2
        if(trim(dcwordlist(mid)) < text) then
            lob = mid + 1
        else if(trim(dcwordlist(mid)) > text) then
            hib = mid
        else!equal
            give = .true.
            return
        endif
    enddo
    give = .false.
    return
end function is_easy

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
        if (inline(i:i) .eq. " " .or. inline(i:i) .eq. achar(10)) then 
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
! normalizes to lowercase
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

end program scores
