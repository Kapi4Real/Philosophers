#include "../philosophers.h"

void	print_status(t_philo *philo, char *status)
{
	pthread_mutex_lock(&philo->data->print_lock);
	if (!philo->data->someone_died)
		printf("%ld %d %s\n", get_time() - philo->data->start_time,
			philo->id, status);
	pthread_mutex_unlock(&philo->data->print_lock);
}
