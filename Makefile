NAME		= philo

CC			= cc
CFLAGS		= -Wall -Wextra -Werror
# CFLAGS	+= -g

SRCS_DIR	= .
UTILS_DIR = utils

SRCS		= parsing.c main.c $(UTILS_DIR)/init.c $(UTILS_DIR)/get_time.c routine.c $(UTILS_DIR)/precise_usleep.c

OBJS		= $(SRCS:.c=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME)
	"
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
