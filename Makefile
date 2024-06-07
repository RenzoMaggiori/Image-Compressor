##
## EPITECH PROJECT, 2023
## imageCompressor
## File description:
## Makefile
##

NAME = imageCompressor

all: build copy

build:
	stack build

copy:
	cp `stack path --local-install-root`/bin/imageCompressor-exe ./$(NAME)

clean:
	stack clean

fclean: clean
	rm -f $(NAME)

re: fclean all
