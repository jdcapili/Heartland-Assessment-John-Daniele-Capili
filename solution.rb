# added named capturing group
# photo_name, extension, city_name, date, time
REGEX_FOR_FILES = /((?<photo_name>\w+)\.(?<extension>jpg|png|jpeg)\,\s(?<city_name>[A-Z][a-z]+)\,\s(?<date>\d{4}\-\d{2}\-\d{2})\s(?<time>\d{2}\:\d{2}\:\d{2}))/
# Alternative for city name regex = /[A-Z][a-z]+/ -> /\w+/ -> works with test case.

# Analysis
# (M is number of photos, N is longest string for photo details)
# M = 100 worst case as mentioned in problem
# N estimate = 
    # (photo name + city name at most 20 characters) +
    # (extension at most 4 characters) +
    # (date + time 19 characters full format count) + 
    # (", " 2*2=4 characters in total)
    # = 47 characters

    # Time complexity for solution -> O(M + M*N + M^2logM + M) -> O(M^2logM)
        # s.split(/\n/) -> O(M)
        # create_files_hash -> O(M*N)
            # arr.each_with_index -> O(M)
                # String#match -> O(N)
                # files_hash[city_name] -> O(1), push is O(M)(at most all photos are under 1 city)
        # generate file names -> O(M * (MlogM + O(M))) -> O(M * MlogM) -> O(M^2logM)
            # iterate through cities -> O(M) -> worst case is that each photo has different cities
                # sort photos in cities by date, time -> O(M log M)
                # files_hash[city].each_with_index -> O(M) -> worst case is all photos under 1 city
        # join output array -> O(M)

def solution(s)
    # split input string "\n"
    arr = s.split(/\n/)
    # create a hash { <city_name>: [[idx,photo_name,extension,city_name,date,time]] }
    files_hash = create_files_hash(arr)

    generate_file_names(files_hash, arr)

    # join arr to a single string
    # separate filenames with newline
    arr.join("\n")
end

def create_files_hash(arr)
    files_hash = Hash.new {|h,k| h[k] = []}
    arr.each_with_index do |file_string,i|
        # String#match returns MatchData class. where we can access named_captures
        # named captures: photo_name,extension,city_name,date,time
        file_details = file_string.match(REGEX_FOR_FILES)
        # add file details as a subarray under city names
        # [idx,photo_name,extension,city_name,date,time]
        files_hash[file_details.named_captures['city_name']] << [
            i,
            *file_details.captures
        ]
    end
    files_hash
end

def generate_file_names(files_hash, arr)
    for city in files_hash.keys
        # sort_by! date and time order.
        files_hash[city].sort_by! do |file_details|
            idx_in_arr, photo_name, extension, city_name, date, time = file_details
            [date,time]
        end

        # check how many digits should the numbers be for the new filenames per city
        # Integer#digits returns arr with ones digit at index zero, and so on... EX: 19.digits -> [9,1] 
        target_num_digits = files_hash[city].size.digits.size

        files_hash[city].each_with_index do |file_details,i|
            idx_in_arr, photo_name, extension, city_name, date, time = file_details

            # new file name is formatted <city_name><i+1 with appended zeros(if any)>.<extension>
            file_name = "#{city_name}#{append_zeros(i+1,target_num_digits)}.#{extension}"
            arr[idx_in_arr] = file_name
        end
    end
end

def append_zeros(n, target_num_digits)
    num_zeros_to_append = target_num_digits - n.digits.size
    n = n.to_s

    ('0' * num_zeros_to_append) + n
end

# Notes about the problem:
    # reorganize photos by:
        # city
            # sort by time
            # assign consecutive natural numbers to photos(from 1...)

    # afterwards, rename all photos
    # new name format:
        # <city name><number assigned to photo><extension>
        # NOTE:
            # The number of every photo in each group should have
            # the same length (equal to the length of the largest number in this group)
            # *ADD LEADING ZEROS

    # Original format:
    # "<<photoname>>.<<extension>>, <<city_name>>, yyyy-mm-dd, hh:mm:ss"
    # <<photoname>>.<<extension>>, <<city_name>> consists of only letters


    # Write a function that, given a string representing the list of M photos,
    # returns the string representing the list of the new names of all photos
    # !!!(the order of photos should stay the same).

    # - M is an integer within the range (1..100); -> M = 100 worst case
    # - Each year is an integer within the range (2000..2020);
    # - Each line of the input string is of the format '<<photoname>>.<<extension>>, <<city_name>>, yyyy-mm-dd hh:mm:ss' and lines are separated with newline characters;
    # - Each photo name (without extension) and city name name consists only of at least 1 and at most 20 letters from the English alphabet;
    # - Each name of the city starts with a capital letters and is followed by lower case letters;
    # - No two photos from the same location share the same date and time;
    # - Each extension is "jpg", "png" or "jpeg". In your solution, focus on correctness.

# Initial pseudo code:
# split input string "\n" -> arr

# Create grouping hash -> files_hash
# {
#     <city_name>: [
#         # sorted array by yyyy-mm-dd, hh:mm:ss -> sort later?
#         [index on original array, "<<photoname>>.<<extension>>, <<city_name>>, yyyy-mm-dd, hh:mm:ss"]
#     ]
# }

# iterate through each city in the hash
    # sort the photos by [date, time]
    # get numbers of photos under the city (x)
    # iterate through each photo
        # create the number to be appended with city name
        # number would be a string with any additional leading zeros if needed depending on x.
        # use the <index on original array> to add new filename <cityname><num with appended zeroes>.<extension> to preserve original order

# return arr joined with "\n"