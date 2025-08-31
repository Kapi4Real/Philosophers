#include "philosophers.h"

void    print_status(t_philo *philo, char *status)
{
    pthread_mutex_lock(&philo->data->print_lock);
    if (!philo->data->someone_died)
        printf("%ld %d %s\n", get_time() - philo->data->start_time, philo->id, status);
    pthread_mutex_unlock(&philo->data->print_lock);
}

static void    take_forks(t_philo *philo)
{
    if (philo->id % 2 == 0)
    {
        pthread_mutex_lock(philo->right_fork);
        print_status(philo, "has taken a fork");
        pthread_mutex_lock(philo->left_fork);
        print_status(philo, "has taken a fork");
    }
    else
    {
        pthread_mutex_lock(philo->left_fork);
        print_status(philo, "has taken a fork");
        pthread_mutex_lock(philo->right_fork);
        print_status(philo, "has taken a fork");
    }
}

static void    eat(t_philo *philo)
{
    print_status(philo, "is eating");
    philo->last_meal = get_time();
    precise_usleep(philo->data->time_to_eat);
    philo->nb_eaten++;
}

static void    release_forks(t_philo *philo)
{
    pthread_mutex_unlock(philo->left_fork);
    pthread_mutex_unlock(philo->right_fork);
}

static void    sleep_and_think(t_philo *philo)
{
    print_status(philo, "is sleeping");
    precise_usleep(philo->data->time_to_sleep);
    print_status(philo, "is thinking");
}

void    *philosopher_routine(void *arg)
{
    t_philo *philo;

    philo = (t_philo *)arg;
    if (philo->data->nb_philos == 1)
    {
        print_status(philo, "has taken a fork");
        precise_usleep(philo->data->time_to_die);
        return (NULL);
    }
    while (!philo->data->someone_died)
    {
        take_forks(philo);
        eat(philo);
        release_forks(philo);
        sleep_and_think(philo);
    }
    return (NULL);
}

void *monitor_routine(void *arg)
{
    t_data  *data;
    int     i;
    long    current_time;

    data = (t_data *)arg;
    while (!data->someone_died)
    {
        i = 0;
        while (i < data->nb_philos)
        {
            current_time = get_time();
            if (current_time - data->philos[i].last_meal > data->time_to_die)
            {
                pthread_mutex_lock(&data->death_lock);
                printf("%ld %d died\n", current_time - data->start_time, data->philos[i].id);
                data->someone_died = 1;
                pthread_mutex_unlock(&data->death_lock);
                return (NULL);
            }
            i++;
        }
        usleep(1000);
    }
    return (NULL);
}


int start_threads(t_data *data)
{
    int i;

    i = 0;
    while (i < data->nb_philos)
    {
        if (pthread_create(&data->philos[i].thread, NULL, philosopher_routine, &data->philos[i]) != 0)
            return (0);
        i++;
    }
    if (pthread_create(&data->monitor, NULL, monitor_routine, data) != 0)
        return (0);
    return (1);
}
