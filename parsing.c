#include "philosophers.h"
#include "limits.h"

static int check_overflow(char **argv,int argc)
{
	int i = 1;
	long num = 0;
	
	while(i < argc)
	{
		num = atoi(argv[i]);
		if(num > INT_MAX || num < 0)
		{
			write(2, "Error: invalid number\n",21);
			return (0);
		}
		i++;
	}
	return (1);
}

int is_number(char *str)
{
	int i =0;
	while(str[i])
	{		
		if (str[i] < '0' || str[i] >'9')
			return 0;
		i++;
	}
	return(1);
}

static int check_arg_count(int argc)
{
    if (argc != 5 && argc != 6)
    {
        write(2, "Error: wrong number of arguments\n", 33);
        return (0);
    }
    return (1);
}

static int check_args_are_numbers(char **argv, int argc)
{
    int i;

    i = 1;
    while (i < argc)
    {
        if (!is_number(argv[i]))
        {
            write(2, "Error: invalid argument\n", 25);
            return (0);
        }
        i++;
    }
    return (1);
}

static void init_data(t_data *data, char **argv, int argc)
{
    data->nb_philos = atoi(argv[1]);
    data->time_to_die = atoi(argv[2]);
    data->time_to_eat = atoi(argv[3]);
    data->time_to_sleep = atoi(argv[4]);
    if (argc == 6)
    {
        data->nb_must_eat = atoi(argv[5]);
        data->is_limited_meals = 1;
    }
    else
    {
        data->nb_must_eat = -1;
        data->is_limited_meals = 0;
    }
    data->someone_died = 0;
}

int parse_args(t_data *data, int argc, char **argv)
{
    if (!check_arg_count(argc))
        return (0);
    if (!check_args_are_numbers(argv, argc))
        return (0);
    if(!check_overflow(argv, argc))
	    return(0);
    init_data(data, argv, argc);
    if (data->nb_philos <= 0 || data->time_to_die <= 0
        || data->time_to_eat <= 0 || data->time_to_sleep <= 0
        || (data->is_limited_meals && data->nb_must_eat <= 0))
    {
        write(2, "Error: invalid values\n", 23);
        return (0);
    }
    return (1);
}
